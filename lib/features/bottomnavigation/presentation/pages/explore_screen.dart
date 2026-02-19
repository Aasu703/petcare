import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare/app/routes/route_paths.dart';
import 'package:petcare/features/services/domain/entities/service_entity.dart';
import 'package:petcare/features/services/presentation/view_model/service_view_model.dart';
import 'package:petcare/shared/widgets/app_empty_state.dart';
import 'package:petcare/shared/widgets/app_error_state.dart';
import 'package:petcare/shared/widgets/app_loading_indicator.dart';
// import 'package:petcare/load'

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
      appBar: AppBar(
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
        title: const Text('Explore Services'),
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
      body: RefreshIndicator(
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final selected = category == _selectedCategory;
                    return ChoiceChip(
                      label: Text(category),
                      selected: selected,
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
                child: AppLoadingIndicator(message: 'Loading services...'),
              )
            else if (state.error != null && state.services.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppErrorState(
                  message: state.error!,
                  onRetry: () =>
                      ref.read(serviceProvider.notifier).loadServices(),
                ),
              )
            else if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
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
                padding: const EdgeInsets.all(16),
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
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceEntity service;
  final VoidCallback onBook;

  const _ServiceCard({required this.service, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            if ((service.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                service.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Chip(label: Text(service.category ?? 'General')),
                const SizedBox(width: 8),
                Text('${service.durationMinutes} min'),
                const Spacer(),
                Text(
                  '\$${service.price.toStringAsFixed(2)}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
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
