import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  static const String _bookingChannelId = 'booking_reminders';
  static const String _vaccinationChannelId = 'vaccination_reminders';
  static const String _generalChannelId = 'general_alerts';

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

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );
    await _createChannels();
    _initialized = true;
  }

  void _handleNotificationTap(NotificationResponse _) {}

  Future<void> _createChannels() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _bookingChannelId,
        'Booking Reminders',
        description: 'Reminders for upcoming pet care appointments',
        importance: Importance.high,
      ),
    );
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _vaccinationChannelId,
        'Vaccination Reminders',
        description: 'Reminders for upcoming pet vaccinations',
        importance: Importance.high,
      ),
    );
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _generalChannelId,
        'General Alerts',
        description: 'General app alerts and updates',
        importance: Importance.high,
      ),
    );
  }

  Future<bool> requestPermissions() async {
    await init();

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final macPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();

    final androidGranted = await androidPlugin
        ?.requestNotificationsPermission();
    final iosGranted = await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    final macGranted = await macPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    final androidAllowed = androidGranted ?? true;
    final iosAllowed = iosGranted ?? true;
    final macAllowed = macGranted ?? true;
    return androidAllowed && iosAllowed && macAllowed;
  }

  Future<bool> areNotificationsEnabled() async {
    await init();
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final macPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();

    final androidEnabled = await androidPlugin?.areNotificationsEnabled();
    final iosPermissions = await iosPlugin?.checkPermissions();
    final macPermissions = await macPlugin?.checkPermissions();

    final androidAllowed = androidEnabled ?? true;
    final iosAllowed = iosPermissions?.isEnabled ?? true;
    final macAllowed = macPermissions?.isEnabled ?? true;
    return androidAllowed && iosAllowed && macAllowed;
  }

  Future<bool> _ensurePermissions() async {
    final enabled = await areNotificationsEnabled();
    if (enabled) return true;
    return requestPermissions();
  }

  /// Schedule a reminder [reminderBefore] before the appointment.
  /// Default: 1 hour before [appointmentTime].
  Future<bool> scheduleBookingReminder({
    required int bookingNotificationId,
    required String title,
    required String body,
    required DateTime appointmentTime,
    Duration reminderBefore = const Duration(hours: 1),
  }) async {
    await init();
    final granted = await _ensurePermissions();
    if (!granted) return false;

    final scheduledTime = appointmentTime.subtract(reminderBefore);

    // Don't schedule if the reminder time is in the past
    if (scheduledTime.isBefore(DateTime.now())) return false;

    final tzScheduled = tz.TZDateTime.from(scheduledTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      _bookingChannelId,
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

    final payload = jsonEncode({
      'type': 'booking',
      'scheduledAt': scheduledTime.toIso8601String(),
    });

    await _plugin.zonedSchedule(
      bookingNotificationId,
      title,
      body,
      tzScheduled,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    return true;
  }

  /// Schedule a reminder before a vaccination due date.
  /// Default: 1 day before [dueDate].
  Future<bool> scheduleVaccinationReminder({
    required int recordNotificationId,
    required String title,
    required String body,
    required DateTime dueDate,
    Duration reminderBefore = const Duration(days: 1),
  }) async {
    await init();
    final granted = await _ensurePermissions();
    if (!granted) return false;

    final scheduledTime = dueDate.subtract(reminderBefore);
    if (scheduledTime.isBefore(DateTime.now())) return false;

    final tzScheduled = tz.TZDateTime.from(scheduledTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      _vaccinationChannelId,
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

    final payload = jsonEncode({
      'type': 'vaccination',
      'scheduledAt': scheduledTime.toIso8601String(),
    });

    await _plugin.zonedSchedule(
      recordNotificationId,
      title,
      body,
      tzScheduled,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    return true;
  }

  Future<bool> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await init();
    final granted = await _ensurePermissions();
    if (!granted) return false;

    const androidDetails = AndroidNotificationDetails(
      _generalChannelId,
      'General Alerts',
      channelDescription: 'General app alerts and updates',
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

    final payload = jsonEncode({
      'type': 'test',
      'scheduledAt': DateTime.now().toIso8601String(),
    });

    await _plugin.show(id, title, body, details, payload: payload);
    return true;
  }

  Future<List<PendingNotificationRequest>> pendingNotifications() async {
    await init();
    return _plugin.pendingNotificationRequests();
  }

  /// Cancel a scheduled notification by its ID.
  Future<void> cancelNotification(int notificationId) async {
    await init();
    await _plugin.cancel(notificationId);
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  static int _stableHash(String value) {
    const int fnvPrime = 0x01000193;
    var hash = 0x811C9DC5;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * fnvPrime) & 0x7FFFFFFF;
    }
    return hash;
  }

  /// Generate a stable notification ID from a booking ID string.
  static int bookingIdToNotificationId(String bookingId) {
    return _stableHash('booking:$bookingId');
  }

  /// Generate a stable notification ID from a health record ID string.
  static int healthRecordIdToNotificationId(String recordId) {
    return _stableHash('health:$recordId');
  }

  static int createEphemeralId() {
    return DateTime.now().millisecondsSinceEpoch % 2147483647;
  }
}
