import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare/app/routes/route_paths.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/features/services/domain/entities/service_entity.dart';
import 'package:petcare/features/services/presentation/view_model/service_view_model.dart';
import 'package:petcare/shared/widgets/index.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _query = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    Future.microtask(() => ref.read(serviceProvider.notifier).loadServices());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 220;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(serviceProvider.notifier).loadMore();
    }
  }

  List<String> _categories(List<ServiceEntity> services) {
    final values =
        services
            .map((service) => service.category?.trim())
            .whereType<String>()
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['All', ...values];
  }

  List<ServiceEntity> _applyFilters(List<ServiceEntity> services) {
    return services.where((service) {
      final matchesQuery =
          _query.isEmpty ||
          service.title.toLowerCase().contains(_query.toLowerCase()) ||
          (service.description ?? '').toLowerCase().contains(
            _query.toLowerCase(),
          );
      final matchesCategory =
          _selectedCategory == 'All' || service.category == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  void _openBooking(ServiceEntity service) {
    final route = Uri(
      path: RoutePaths.bookingNew,
      queryParameters: {
        if (service.providerId != null) 'providerId': service.providerId,
        if (service.serviceId != null) 'serviceId': service.serviceId,
        'price': service.price.toString(),
      },
    ).toString();
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serviceProvider);
    final categories = _categories(state.services);
    final filtered = _applyFilters(state.services);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(RoutePaths.home);
            }
          },
        ),
        title: Text(
          'Explore Services',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          if (_selectedCategory != 'All' || _query.isNotEmpty)
            IconButton(
              tooltip: 'Clear filters',
              onPressed: () {
                setState(() {
                  _selectedCategory = 'All';
                  _searchController.clear();
                  _query = '';
                });
              },
              icon: const Icon(Icons.filter_alt_off_rounded),
            ),
          IconButton(
            tooltip: 'Book Appointment',
            onPressed: () => context.push(RoutePaths.bookingNew),
            icon: const Icon(Icons.calendar_month_rounded),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.backgroundColor,
              context.surfaceColor.withOpacity(context.isDark ? 0.35 : 0.85),
            ],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () => ref.read(serviceProvider.notifier).loadServices(),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search by service name or description',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                      filled: true,
                      fillColor: context.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 46,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final selected = category == _selectedCategory;
                      return ChoiceChip(
                        label: Text(category),
                        selected: selected,
                        showCheckmark: false,
                        selectedColor: context.primaryColor.withOpacity(0.14),
                        backgroundColor: context.surfaceColor,
                        side: BorderSide(color: context.borderColor),
                        labelStyle: TextStyle(
                          color: selected
                              ? context.primaryColor
                              : context.textSecondary,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                        onSelected: (_) {
                          setState(() => _selectedCategory = category);
                        },
                      );
                    },
                  ),
                ),
              ),
              if (state.isLoading && state.services.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: LoadingIndicator(message: 'Loading services...'),
                )
              else if (state.error != null && state.services.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorState(
                    title: 'Error loading services',
                    message: state.error,
                    actionLabel: 'Retry',
                    onAction: () =>
                        ref.read(serviceProvider.notifier).loadServices(),
                  ),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    title: 'No services found',
                    subtitle: 'Try a different search or category.',
                    icon: Icons.search_off_rounded,
                    onAction: () {
                      _searchController.clear();
                      setState(() {
                        _query = '';
                        _selectedCategory = 'All';
                      });
                    },
                    actionLabel: 'Clear filters',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  sliver: SliverList.builder(
                    itemCount: filtered.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filtered.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final service = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ServiceCard(
                          service: service,
                          onBook: () => _openBooking(service),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceEntity service;
  final VoidCallback onBook;

  const _ServiceCard({required this.service, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -14,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            if ((service.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                service.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: context.textSecondary),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    service.category ?? 'General',
                    style: TextStyle(
                      color: context.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.accentColor.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${service.durationMinutes} min',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  '\$${service.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.primaryColor,
                  ),
                ),
                const Spacer(),
                Text(
                  'per session',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: onBook,
                icon: const Icon(Icons.calendar_today_rounded),
                label: const Text('Book'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
