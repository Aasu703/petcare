import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare/app/routes/route_paths.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/features/provider/domain/entities/provider_entity.dart';
import 'package:petcare/features/provider/presentation/view_model/provider_view_model.dart';
import 'package:petcare/features/pet/presentation/view_model/pet_view_model.dart';
import 'package:petcare/shared/widgets/index.dart' hide OutlinedButton;

class ProviderDetailPage extends ConsumerStatefulWidget {
  final String providerId;

  const ProviderDetailPage({super.key, required this.providerId});

  @override
  ConsumerState<ProviderDetailPage> createState() => _ProviderDetailPageState();
}

class _ProviderDetailPageState extends ConsumerState<ProviderDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(providerListProvider.notifier).loadProviders();
    });
  }

  ProviderEntity? _findProvider(List<ProviderEntity> providers) {
    try {
      return providers.firstWhere((p) => p.providerId == widget.providerId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(providerListProvider);
    final provider = _findProvider(state.providers);

    if (state.isLoading && provider == null) {
      return const Scaffold(
        body: LoadingIndicator(message: 'Loading provider...'),
      );
    }

    if (provider == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const ErrorState(
          title: 'Provider not found',
          message: 'The provider could not be found.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero header with gradient overlay
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: context.primaryColor,
                leading: _CircleBackButton(onPressed: () => context.pop()),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'provider_${provider.providerId}',
                        child: _buildHeaderImage(provider),
                      ),
                      // Gradient overlay for readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                      ),
                      // Provider type badge
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 48,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            provider.providerType == 'vet'
                                ? 'Veterinarian'
                                : provider.providerType == 'babysitter'
                                    ? 'Grooming'
                                    : 'Boarding',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: context.primaryColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Info card (overlapping)
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -28),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          provider.businessName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        // Degree
                        if (provider.degree != null && provider.degree!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            provider.degree!,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: context.primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        // Certification
                        if (provider.certification != null &&
                            provider.certification!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            provider.certification!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.primaryColor.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),

                        // Rating row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFA000).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded,
                                      size: 16, color: Color(0xFFFFA000)),
                                  const SizedBox(width: 4),
                                  Text(
                                    provider.rating.toDouble().toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${provider.ratingCount} reviews',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Info chips row
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (provider.workingHours != null &&
                                provider.workingHours!.isNotEmpty)
                              _InfoChip(
                                icon: Icons.schedule_rounded,
                                label: provider.workingHours!,
                                iconColor: context.primaryColor,
                              ),
                            if (provider.experience != null &&
                                provider.experience!.isNotEmpty)
                              _InfoChip(
                                icon: Icons.workspace_premium_rounded,
                                label: provider.experience!,
                                iconColor: AppColors.warningColor,
                              ),
                          ],
                        ),

                        // Appointment fee
                        if (provider.appointmentFee != null &&
                            provider.appointmentFee! > 0) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: context.primaryColor.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: context.primaryColor.withOpacity(0.15),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.payments_rounded,
                                    size: 18, color: context.primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  'LKR ${provider.appointmentFee!.toStringAsFixed(0)} per Appointment',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: context.primaryColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Bio/About section
              if (provider.bio != null && provider.bio!.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.bio!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Recommended For (user's pets)
              SliverToBoxAdapter(child: _RecommendedForSection()),

              // Reviews button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  child: Material(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.push(
                        '${RoutePaths.providerReviews}/${widget.providerId}',
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.borderColor),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFA000).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.star_rounded,
                                  color: Color(0xFFFFA000), size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Reviews & Ratings',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    '${provider.ratingCount} reviews from pet owners',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: context.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: context.hintColor),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom spacing for button
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // Fixed "Book an Appointment" button
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 12,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.primaryColor.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final route = Uri(
                      path: RoutePaths.bookingNew,
                      queryParameters: {
                        'providerId': provider.providerId ?? '',
                        if (provider.appointmentFee != null)
                          'price': provider.appointmentFee.toString(),
                      },
                    ).toString();
                    context.push(route);
                  },
                  icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
                  label: const Text(
                    'Book an Appointment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(ProviderEntity provider) {
    if (provider.profileImageUrl != null && provider.profileImageUrl!.isNotEmpty) {
      final url = provider.profileImageUrl!.startsWith('http')
          ? provider.profileImageUrl!
          : ApiEndpoints.resolveMediaUrl(provider.profileImageUrl!);
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderHeader(provider),
      );
    }
    return _placeholderHeader(provider);
  }

  Widget _placeholderHeader(ProviderEntity provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.primaryColor.withOpacity(0.15),
            AppColors.primaryLightColor.withOpacity(0.2),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          provider.providerType == 'vet'
              ? Icons.local_hospital_rounded
              : provider.providerType == 'babysitter'
                  ? Icons.content_cut_rounded
                  : Icons.house_rounded,
          size: 80,
          color: context.primaryColor.withOpacity(0.3),
        ),
      ),
    );
  }
}

// ── Circle back button ──────────────────────────────────────────────────
class _CircleBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _CircleBackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

// ── Info chip ────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: context.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recommended For Section ─────────────────────────────────────────────
class _RecommendedForSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petState = ref.watch(petViewModelProvider);
    final pets = petState.pets;

    if (pets.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pets_rounded, size: 16, color: AppColors.accentColor),
              const SizedBox(width: 6),
              Text(
                'Recommended For Your Pets',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pets.take(4).map((pet) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accentColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pets_rounded,
                        size: 12, color: AppColors.accentColor),
                    const SizedBox(width: 6),
                    Text(
                      pet.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
