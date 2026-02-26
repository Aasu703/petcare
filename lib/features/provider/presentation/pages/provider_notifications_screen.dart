import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/core/services/notification/notification_service.dart';

class ProviderNotificationsScreen extends ConsumerStatefulWidget {
  const ProviderNotificationsScreen({super.key});

  @override
  ConsumerState<ProviderNotificationsScreen> createState() =>
      _ProviderNotificationsScreenState();
}

class _ProviderNotificationsScreenState
    extends ConsumerState<ProviderNotificationsScreen> {
  bool _isLoading = true;
  bool _isRequestingPermission = false;
  bool _isNotificationsEnabled = true;
  String? _error;
  List<PendingNotificationRequest> _pending = const [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_refreshData);
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final service = ref.read(notificationServiceProvider);
    try {
      final enabled = await service.areNotificationsEnabled();
      final pending = await service.pendingNotifications();
      if (!mounted) return;
      setState(() {
        _isNotificationsEnabled = enabled;
        _pending = pending;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    setState(() => _isRequestingPermission = true);
    final service = ref.read(notificationServiceProvider);
    final granted = await service.requestPermissions();
    if (!mounted) return;
    setState(() {
      _isRequestingPermission = false;
      _isNotificationsEnabled = granted;
    });
    await _refreshData();
  }

  Future<void> _sendTestNotification() async {
    final service = ref.read(notificationServiceProvider);
    final sent = await service.showInstantNotification(
      id: NotificationService.createEphemeralId(),
      title: 'PetCare test notification',
      body: 'Notifications are set up correctly on this device.',
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sent
              ? 'Test notification sent.'
              : 'Notification permission is disabled.',
        ),
      ),
    );
    await _refreshData();
  }

  Future<void> _clearAllScheduled() async {
    final service = ref.read(notificationServiceProvider);
    await service.cancelAll();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('All notifications cleared.')));
    await _refreshData();
  }

  String _formatDate(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.year}-$month-$day $hour:$minute';
  }

  String _requestSubtitle(PendingNotificationRequest request) {
    final payload = request.payload;
    if (payload == null || payload.isEmpty) {
      return 'Notification ID: ${request.id}';
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        return 'Notification ID: ${request.id}';
      }

      final type = (decoded['type'] ?? '').toString();
      final scheduledAt = DateTime.tryParse(
        (decoded['scheduledAt'] ?? '').toString(),
      );

      final segments = <String>[];
      if (type.isNotEmpty) {
        segments.add('Type: $type');
      }
      if (scheduledAt != null) {
        segments.add('At: ${_formatDate(scheduledAt.toLocal())}');
      }

      if (segments.isEmpty) {
        return 'Notification ID: ${request.id}';
      }
      return segments.join(' • ');
    } catch (_) {
      return 'Notification ID: ${request.id}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isNotificationsEnabled
                              ? Icons.notifications_active
                              : Icons.notifications_off,
                          color: _isNotificationsEnabled
                              ? context.successColor
                              : context.warningColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _isNotificationsEnabled
                                ? 'Notifications are enabled.'
                                : 'Notifications are disabled.',
                            style: TextStyle(
                              color: context.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!_isNotificationsEnabled)
                          TextButton(
                            onPressed: _isRequestingPermission
                                ? null
                                : _requestPermission,
                            child: _isRequestingPermission
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Enable'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _sendTestNotification,
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: const Text('Send Test'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pending.isEmpty
                              ? null
                              : _clearAllScheduled,
                          icon: const Icon(Icons.clear_all_rounded, size: 18),
                          label: const Text('Clear All'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Scheduled reminders (${_pending.length})',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_error != null)
                    Text(_error!, style: TextStyle(color: context.errorColor)),
                  if (_pending.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Text(
                        'No reminders are currently scheduled.',
                        style: TextStyle(color: context.textSecondary),
                      ),
                    ),
                  if (_pending.isNotEmpty)
                    ..._pending.map(
                      (request) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.surfaceColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: context.borderColor),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.notifications_none_rounded,
                              color: context.primaryColor,
                            ),
                            title: Text(
                              request.title ?? 'Untitled notification',
                              style: TextStyle(
                                color: context.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              request.body?.isNotEmpty == true
                                  ? '${request.body}\n${_requestSubtitle(request)}'
                                  : _requestSubtitle(request),
                              style: TextStyle(
                                color: context.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            isThreeLine: true,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
