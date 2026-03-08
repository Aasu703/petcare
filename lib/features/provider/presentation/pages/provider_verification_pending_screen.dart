import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare/app/routes/route_paths.dart';
import 'package:petcare/core/session/session_provider.dart';
import 'package:petcare/features/provider/domain/usecases/get_provider_usecase.dart';
import 'package:petcare/features/provider/presentation/provider/provider_providers.dart';

class ProviderVerificationPendingScreen extends ConsumerStatefulWidget {
  const ProviderVerificationPendingScreen({super.key});

  @override
  ConsumerState<ProviderVerificationPendingScreen> createState() =>
      _ProviderVerificationPendingScreenState();
}

class _ProviderVerificationPendingScreenState
    extends ConsumerState<ProviderVerificationPendingScreen> {
  bool _checking = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!mounted || _checking) return;
      _checkStatus(showFeedbackIfPending: false);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus({bool showFeedbackIfPending = true}) async {
    final session = ref.read(sessionProvider);
    final providerId = session.userId;
    if (providerId == null || providerId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing provider session. Please login again.'),
        ),
      );
      return;
    }

    setState(() => _checking = true);

    final usecase = ref.read(getProviderUsecaseProvider);
    final result = await usecase(
      GetProviderUsecaseParams(providerId: providerId),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (provider) async {
        await ref
            .read(sessionProvider.notifier)
            .setSession(
              userId: provider.providerId ?? providerId,
              firstName: provider.businessName,
              lastName: '',
              email: provider.email ?? session.email ?? '',
              role: 'provider',
              providerType: provider.providerType,
              providerStatus: provider.status,
            );

        if (!mounted) return;

        final approved =
            (provider.status ?? '').trim().toLowerCase() == 'approved';
        if (approved) {
          context.go(RoutePaths.providerDashboard);
          return;
        }

        if (showFeedbackIfPending) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Still pending admin approval. Please check again later.',
              ),
            ),
          );
        }
      },
    );

    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Pending')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hourglass_top_rounded, size: 72),
              const SizedBox(height: 16),
              const Text(
                'Your provider account is under admin review.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'You can access the provider dashboard once your account is approved.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _checking ? null : () => _checkStatus(),
                  child: _checking
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Check Approval Status'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.go(RoutePaths.providerLogin),
                child: const Text('Back to Provider Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
