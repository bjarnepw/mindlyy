import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Call this once at app startup
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize timezone database
    tz_data.initializeTimeZones();

    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName as String));
    } catch (e) {
      debugPrint('Timezone init failed, defaulting to UTC: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // Notification initialization
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false, // we handle permissions manually
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _notifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // Request permissions
    await requestPermissions();
  }

  /// Requests all necessary permissions for notifications
  static Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      // Notification permission (Android 13+)
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final newStatus = await Permission.notification.request();
        debugPrint('Notification permission: $newStatus');
      }

      // Exact alarm permission (for timers/reminders)
      final alarmStatus = await Permission.scheduleExactAlarm.status;
      if (!alarmStatus.isGranted) {
        await Permission.scheduleExactAlarm.request();
      }
    }
  }

  /// Schedules a reminder notification
  static Future<void> scheduleReminder(
    String name,
    int value,
    String unit,
    String stringId,
  ) async {
    Duration duration;
    switch (unit) {
      case 'minutes':
        duration = Duration(minutes: value);
        break;
      case 'hours':
        duration = Duration(hours: value);
        break;
      default:
        duration = Duration(days: value);
    }

    final id = stringId.hashCode & 0x7fffffff;
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(duration);

    await _notifications.zonedSchedule(
      id,
      'Time to text $name!',
      'Mindlyy: Keep the connection alive ✨',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mindlyy_reminders',
          'Reminders',
          channelDescription: 'Friendship reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      //uiLocalNotificationDateInterpretation:
      //DateInterpretation.absoluteTime,
    );
  }

  /// Cancel a specific notification
  static Future<void> cancel(String stringId) async {
    await _notifications.cancel(stringId.hashCode & 0x7fffffff);
  }

  /// Show an instant test notification
  static Future<void> showInstantNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'mindlyy_test',
      'Test Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      999,
      'Mindlyy Test ✅',
      'If you see this, notifications are working!',
      notificationDetails,
    );
  }
}
