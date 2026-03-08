import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/features/provider_service/presentation/view_model/provider_service_view_model.dart';
import 'package:petcare/app/l10n/app_localizations.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/provider_service/presentation/pages/apply_provider_service.dart';

class MyProviderServicesScreen extends ConsumerStatefulWidget {
  const MyProviderServicesScreen({super.key});

  @override
  ConsumerState<MyProviderServicesScreen> createState() =>
      _MyProviderServicesScreenState();
}

class _MyProviderServicesScreenState
    extends ConsumerState<MyProviderServicesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(providerServiceProvider.notifier).loadMyServices(),
    );
  }

  Future<void> _refresh() async {
    await ref.read(providerServiceProvider.notifier).loadMyServices();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(providerServiceProvider);
    final session = ref.watch(userSessionServiceProvider);
    final providerType = session.getProviderType();
    final normalized = (providerType ?? '').toLowerCase();
    final initialServiceType = normalized.contains('vet')
        ? 'vet'
        : normalized.contains('groom') || normalized.contains('baby')
        ? 'grooming'
        : 'boarding';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('myServices'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ApplyProviderServiceScreen(
                initialServiceType: initialServiceType,
                lockServiceType: true,
              ),
            ),
          ).then((_) => _refresh());
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.tr('addService')),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primaryColor,
        child: state.isLoading && state.services.isEmpty
            ? Center(child: CircularProgressIndicator())
            : state.services.isEmpty
            ? Center(child: Text(l10n.tr('noServicesYet')))
            : ListView.separated(
                padding: EdgeInsets.all(12),
                itemCount: state.services.length,
                separatorBuilder: (_, __) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final s = state.services[index];

                  // Determine status color and label
                  final statusColor = s.approvalStatus == 'approved'
                      ? Color.fromARGB(255, 34, 197, 94) // green
                      : s.approvalStatus == 'rejected'
                      ? Color.fromARGB(255, 239, 68, 68) // red
                      : Color.fromARGB(255, 251, 191, 36); // amber

                  final statusLabel = s.approvalStatus == 'approved'
                      ? l10n.tr('approved')
                      : s.approvalStatus == 'rejected'
                      ? l10n.tr('rejected')
                      : l10n.tr('pending');

                  return Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                s.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(36),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Category: ${s.category}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Price: ${s.price.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Duration: ${s.durationMinutes} mins',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        if (s.description != null && s.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              s.description!,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
