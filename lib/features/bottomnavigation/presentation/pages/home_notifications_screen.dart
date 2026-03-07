import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:petcare/app/l10n/app_localizations.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/core/services/notification/notification_service.dart';
import 'package:petcare/features/health_records/presentation/state/vaccination_reminder_state.dart';
import 'package:petcare/features/health_records/presentation/view_model/vaccination_reminder_view_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomeNotificationsScreen extends ConsumerStatefulWidget {
  final List<String> petIds;

  const HomeNotificationsScreen({super.key, required this.petIds});

  @override
  ConsumerState<HomeNotificationsScreen> createState() =>
      _HomeNotificationsScreenState();
}

class _HomeNotificationsScreenState
    extends ConsumerState<HomeNotificationsScreen> {
  bool _loadingPending = true;
  List<PendingNotificationRequest> _pending = const [];
  bool _requestedReminders = false;

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    final service = ref.read(notificationServiceProvider);
    final pending = await service.pendingNotifications();
    if (!mounted) return;
    setState(() {
      _pending = pending;
      _loadingPending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reminderState = ref.watch(vaccinationReminderProvider);

    // Ensure reminders are loaded for provided pets when entering the screen.
    if (widget.petIds.isNotEmpty && !_requestedReminders) {
      _requestedReminders = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(vaccinationReminderProvider.notifier)
            .loadReminders(widget.petIds);
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('notifications')), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadPending();
          await ref
              .read(vaccinationReminderProvider.notifier)
              .loadReminders(widget.petIds);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader(l10n.tr('reminders')),
            const SizedBox(height: 8),
            _buildReminderList(reminderState),
            const SizedBox(height: 16),
            _buildSectionHeader(l10n.tr('notifications')),
            const SizedBox(height: 8),
            _buildPendingList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildReminderList(VaccinationReminderState state) {
    if (state.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (state.error != null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          state.error!,
          style: TextStyle(color: AppColors.errorColor),
        ),
      );
    }
    if (state.reminders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text('No reminders are currently scheduled.'),
      );
    }

    return Column(
      children: state.reminders
          .map(
            (reminder) => Card(
              child: ListTile(
                leading: const Icon(Icons.vaccines_rounded),
                title: Text(reminder.title ?? 'Vaccination Reminder'),
                subtitle: _formatDue(reminder.nextDueDate),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _formatDue(String? dateStr) {
    final parsed = DateTime.tryParse(dateStr ?? '');
    if (parsed == null) return const Text('No schedule');
    final formatted = DateFormat.yMMMEd().add_jm().format(parsed.toLocal());
    return Text('Due on $formatted');
  }

  Widget _buildPendingList() {
    if (_loadingPending) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_pending.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text('No pending notifications.'),
      );
    }

    return Column(
      children: _pending
          .map(
            (item) => Card(
              child: ListTile(
                leading: const Icon(Icons.notifications_active_rounded),
                title: Text(item.title ?? 'Untitled notification'),
                subtitle: Text(item.body ?? 'Notification ID: ${item.id}'),
                trailing: Text('#${item.id}'),
              ),
            ),
          )
          .toList(),
    );
  }
}
