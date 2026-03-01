import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare/app/routes/route_paths.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/features/provider/domain/entities/provider_entity.dart';
import 'package:petcare/features/provider/presentation/view_model/provider_view_model.dart';
import 'package:petcare/shared/widgets/index.dart' hide OutlinedButton;

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'vet';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final _categoryOptions = [
    {'key': 'vet', 'label': 'Veterinary', 'icon': Icons.local_hospital_rounded},
    {'key': 'babysitter', 'label': 'Grooming', 'icon': Icons.content_cut_rounded},
    {'key': 'shop', 'label': 'Boarding', 'icon': Icons.house_rounded},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(providerListProvider.notifier).loadProviders());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProviderEntity> _filteredProviders(List<ProviderEntity> providers) {
    return providers.where((p) {
      final matchesCategory = p.providerType == _selectedCategory;
      final matchesStatus = p.status == 'approved';
      final matchesSearch = _searchQuery.isEmpty ||
          p.businessName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.degree ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.clinicOrShopName ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesStatus && matchesSearch;
    }).toList();
  }

  String _categoryLabel(String key) {
    switch (key) {
      case 'vet':
        return 'Veterinarians';
      case 'babysitter':
        return 'Grooming Salons';
      case 'shop':
        return 'Boarding Places';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(providerListProvider);
    final allProviders = state.providers;
    final filtered = _filteredProviders(allProviders);
    final nearby = filtered.where((p) => p.pawcareVerified).take(5).toList();
    final recommended = filtered;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // Gradient header
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: context.primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go(RoutePaths.home);
                }
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.primaryColor,
                      context.primaryColor.withOpacity(0.85),
                      AppColors.primaryLightColor,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Find the Best Care',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'for your furry friends',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Search bar
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search by name, degree, clinic...',
                              hintStyle: TextStyle(
                                color: context.hintColor,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: context.primaryColor,
                                size: 22,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.close_rounded, size: 18, color: context.hintColor),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        body: state.isLoading
            ? const LoadingIndicator(message: 'Loading providers...')
            : state.error != null
                ? ErrorState(
                    title: 'Error loading providers',
                    message: state.error,
                    actionLabel: 'Retry',
                    onAction: () =>
                        ref.read(providerListProvider.notifier).loadProviders(),
                  )
                : RefreshIndicator(
                    onRefresh: () async =>
                        ref.read(providerListProvider.notifier).loadProviders(),
                    color: context.primaryColor,
                    child: ListView(
                      padding: const EdgeInsets.only(top: 20, bottom: 24),
                      children: [
                        // Category selector
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _categoryOptions.map((opt) {
                              final key = opt['key'] as String;
                              final label = opt['label'] as String;
                              final icon = opt['icon'] as IconData;
                              final selected = _selectedCategory == key;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedCategory = key),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                  child: Column(
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 250),
                                        width: 68,
                                        height: 68,
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? context.primaryColor
                                              : context.surfaceColor,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: selected
                                                ? context.primaryColor
                                                : context.borderColor,
                                            width: selected ? 2 : 1.5,
                                          ),
                                          boxShadow: selected
                                              ? [
                                                  BoxShadow(
                                                    color: context.primaryColor.withOpacity(0.3),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Icon(
                                          icon,
                                          size: 30,
                                          color: selected ? Colors.white : context.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        label,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                                          color: selected
                                              ? context.primaryColor
                                              : context.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Nearby section header
                        if (nearby.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _SectionHeader(
                              title: 'Nearby ${_categoryLabel(_selectedCategory)}',
                              icon: Icons.near_me_rounded,
                              iconColor: AppColors.accentColor,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Horizontal scroll for nearby
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: nearby.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: _NearbyCard(
                                    provider: nearby[index],
                                    onTap: () => context.push(
                                      '${RoutePaths.providerDetail}/${nearby[index].providerId}',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Recommended section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _SectionHeader(
                            title: 'All ${_categoryLabel(_selectedCategory)}',
                            icon: Icons.star_rounded,
                            iconColor: const Color(0xFFFFA000),
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (recommended.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.search_off_rounded,
                                      size: 52, color: context.hintColor.withOpacity(0.5)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No ${_categoryLabel(_selectedCategory).toLowerCase()} found',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: context.textSecondary,
                                    ),
                                  ),
                                  if (_searchQuery.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Try a different search term',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: context.hintColor,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...recommended.map((provider) => Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                                child: _ProviderCard(
                                  provider: provider,
                                  onTap: () => context.push(
                                    '${RoutePaths.providerDetail}/${provider.providerId}',
                                  ),
                                ),
                              )),
                      ],
                    ),
                  ),
      ),
    );
  }
}

// ── Section header ──────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ── Horizontal nearby card ──────────────────────────────────────────────
class _NearbyCard extends StatelessWidget {
  final ProviderEntity provider;
  final VoidCallback onTap;

  const _NearbyCard({required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: _buildImage(provider),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.businessName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (provider.degree != null && provider.degree!.isNotEmpty)
                    Text(
                      provider.degree!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: const Color(0xFFFFA000)),
                      const SizedBox(width: 2),
                      Text(
                        provider.rating.toDouble().toStringAsFixed(1),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${provider.ratingCount})',
                        style: TextStyle(fontSize: 10, color: context.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(ProviderEntity provider) {
    if (provider.profileImageUrl != null && provider.profileImageUrl!.isNotEmpty) {
      final url = provider.profileImageUrl!.startsWith('http')
          ? provider.profileImageUrl!
          : ApiEndpoints.resolveMediaUrl(provider.profileImageUrl!);
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(provider),
      );
    }
    return _placeholder(provider);
  }

  Widget _placeholder(ProviderEntity provider) {
    return Container(
      color: AppColors.primaryLightColor.withOpacity(0.15),
      child: Center(
        child: Icon(
          provider.providerType == 'vet'
              ? Icons.local_hospital_rounded
              : provider.providerType == 'babysitter'
                  ? Icons.content_cut_rounded
                  : Icons.house_rounded,
          size: 32,
          color: AppColors.primaryColor.withOpacity(0.4),
        ),
      ),
    );
  }
}

// ── Main provider list card ─────────────────────────────────────────────
class _ProviderCard extends StatelessWidget {
  final ProviderEntity provider;
  final VoidCallback onTap;

  const _ProviderCard({required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOpen = _isCurrentlyOpen(provider.workingHours);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Photo
            Hero(
              tag: 'provider_${provider.providerId}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _buildProviderImage(provider),
              ),
            ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    provider.businessName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Degree
                  if (provider.degree != null && provider.degree!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      provider.degree!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  // Rating
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        return Icon(
                          i < provider.rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 15,
                          color: const Color(0xFFFFA000),
                        );
                      }),
                      const SizedBox(width: 6),
                      Text(
                        '${provider.rating.toDouble().toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        ' (${provider.ratingCount})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Tags row: Open/Closed + Experience + Price
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _TagChip(
                        label: isOpen ? 'OPEN' : 'CLOSED',
                        bgColor: isOpen
                            ? AppColors.successColor.withOpacity(0.1)
                            : AppColors.errorColor.withOpacity(0.1),
                        textColor: isOpen ? AppColors.successColor : AppColors.errorColor,
                      ),
                      if (provider.experience != null && provider.experience!.isNotEmpty)
                        _TagChip(
                          label: provider.experience!,
                          bgColor: context.primaryColor.withOpacity(0.08),
                          textColor: context.primaryColor,
                        ),
                      if (provider.appointmentFee != null && provider.appointmentFee! > 0)
                        _TagChip(
                          label: 'LKR ${provider.appointmentFee!.toStringAsFixed(0)}',
                          bgColor: AppColors.warningColor.withOpacity(0.1),
                          textColor: AppColors.warningColor,
                        ),
                    ],
                  ),
                  // Working hours
                  if (provider.workingHours != null && provider.workingHours!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 13, color: context.hintColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            provider.workingHours!,
                            style: TextStyle(
                              fontSize: 11,
                              color: context.hintColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Arrow
            Icon(Icons.chevron_right_rounded, color: context.hintColor, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderImage(ProviderEntity provider) {
    if (provider.profileImageUrl != null && provider.profileImageUrl!.isNotEmpty) {
      final url = provider.profileImageUrl!.startsWith('http')
          ? provider.profileImageUrl!
          : ApiEndpoints.resolveMediaUrl(provider.profileImageUrl!);
      return Image.network(
        url,
        width: 82,
        height: 82,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderImage(provider),
      );
    }
    return _placeholderImage(provider);
  }

  Widget _placeholderImage(ProviderEntity provider) {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        color: AppColors.primaryLightColor.withOpacity(0.12),
      ),
      child: Icon(
        provider.providerType == 'vet'
            ? Icons.local_hospital_rounded
            : provider.providerType == 'babysitter'
                ? Icons.content_cut_rounded
                : Icons.house_rounded,
        size: 34,
        color: AppColors.primaryColor.withOpacity(0.5),
      ),
    );
  }

  bool _isCurrentlyOpen(String? workingHours) {
    final now = DateTime.now();
    final hour = now.hour;
    final weekday = now.weekday;
    if (weekday >= 6) return false;
    return hour >= 8 && hour < 17;
  }
}

// ── Small tag chip ──────────────────────────────────────────────────────
class _TagChip extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const _TagChip({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }
}
