import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/features/provider_service/presentation/view_model/provider_service_view_model.dart';
import 'package:petcare/app/l10n/app_localizations.dart';

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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('myServices'))),
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

                  return ListTile(
                    title: Text(s.serviceType),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${s.verificationStatus}'),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(51),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: s.ratingAverage != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text((s.ratingAverage!).toStringAsFixed(1)),
                              Text(
                                '${s.ratingCount ?? 0} reviews',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          )
                        : null,
                  );
                },
              ),
      ),
    );
  }
}
