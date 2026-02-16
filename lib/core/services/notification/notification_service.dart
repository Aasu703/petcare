import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification system. Call once at app startup.
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  /// Schedule a reminder [reminderBefore] before the appointment.
  /// Default: 1 hour before [appointmentTime].
  Future<void> scheduleBookingReminder({
    required int bookingNotificationId,
    required String title,
    required String body,
    required DateTime appointmentTime,
    Duration reminderBefore = const Duration(hours: 1),
  }) async {
    await init();

    final scheduledTime = appointmentTime.subtract(reminderBefore);

    // Don't schedule if the reminder time is in the past
    if (scheduledTime.isBefore(DateTime.now())) return;

    final tzScheduled = tz.TZDateTime.from(scheduledTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'booking_reminders',
      'Booking Reminders',
      channelDescription: 'Reminders for upcoming pet care appointments',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      bookingNotificationId,
      title,
      body,
      tzScheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Schedule a reminder before a vaccination due date.
  /// Default: 1 day before [dueDate].
  Future<void> scheduleVaccinationReminder({
    required int recordNotificationId,
    required String title,
    required String body,
    required DateTime dueDate,
    Duration reminderBefore = const Duration(days: 1),
  }) async {
    await init();

    final scheduledTime = dueDate.subtract(reminderBefore);
    if (scheduledTime.isBefore(DateTime.now())) return;

    final tzScheduled = tz.TZDateTime.from(scheduledTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'vaccination_reminders',
      'Vaccination Reminders',
      channelDescription: 'Reminders for upcoming pet vaccinations',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      recordNotificationId,
      title,
      body,
      tzScheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel a scheduled notification by its ID.
  Future<void> cancelNotification(int notificationId) async {
    await _plugin.cancel(notificationId);
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Generate a stable notification ID from a booking ID string.
  static int bookingIdToNotificationId(String bookingId) {
    return bookingId.hashCode.abs() % 2147483647;
  }

  /// Generate a stable notification ID from a health record ID string.
  static int healthRecordIdToNotificationId(String recordId) {
    return recordId.hashCode.abs() % 2147483647;
  }
}
