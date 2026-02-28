import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/features/provider_service/presentation/view_model/provider_service_view_model.dart';

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
    final state = ref.watch(providerServiceProvider);

    return Scaffold(
      appBar: AppBar(title: Text('My Services')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primaryColor,
        child: state.isLoading && state.services.isEmpty
            ? Center(child: CircularProgressIndicator())
            : state.services.isEmpty
            ? Center(child: Text('No services yet'))
            : ListView.separated(
                padding: EdgeInsets.all(12),
                itemCount: state.services.length,
                separatorBuilder: (_, __) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final s = state.services[index];
                  return ListTile(
                    title: Text(s.serviceType),
                    subtitle: Text('Status: ${s.verificationStatus}'),
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
