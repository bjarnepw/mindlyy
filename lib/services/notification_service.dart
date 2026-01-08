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
      debugPrint('Setting timezone to: $timezoneName');
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (e) {
      debugPrint('Timezone init failed, defaulting to UTC: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // Notification initialization
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _notifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // Create notification channels explicitly (Android 8.0+)
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }

    // Request permissions
    await requestPermissions();
  }

  /// Creates notification channels for Android
  static Future<void> _createNotificationChannels() async {
    const reminderChannel = AndroidNotificationChannel(
      'mindlyy_reminders',
      'Reminders',
      description: 'Friendship reminders',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );

    const testChannel = AndroidNotificationChannel(
      'mindlyy_test',
      'Test Notifications',
      description: 'Test notifications',
      importance: Importance.max,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(reminderChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(testChannel);

    debugPrint('Notification channels created');
  }

  /// Requests all necessary permissions for notifications
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // Notification permission (Android 13+)
      final status = await Permission.notification.status;
      debugPrint('Initial notification permission: $status');

      if (!status.isGranted) {
        final newStatus = await Permission.notification.request();
        debugPrint('Notification permission after request: $newStatus');
        if (!newStatus.isGranted) {
          debugPrint('WARNING: Notification permission not granted!');
          return false;
        }
      }

      // Exact alarm permission (for timers/reminders)
      final alarmStatus = await Permission.scheduleExactAlarm.status;
      debugPrint('Schedule exact alarm permission: $alarmStatus');

      if (!alarmStatus.isGranted) {
        final newAlarmStatus = await Permission.scheduleExactAlarm.request();
        debugPrint('Exact alarm permission after request: $newAlarmStatus');
        if (!newAlarmStatus.isGranted) {
          debugPrint('WARNING: Exact alarm permission not granted! Notifications may not work.');
          return false;
        }
      }

      return true;
    }
    return true;
  }

  /// Schedules a reminder notification
  static Future<void> scheduleReminder(
    String name,
    int value,
    String unit,
    String stringId,
  ) async {
    try {
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

      debugPrint('Scheduling notification for $name');
      debugPrint('  ID: $id');
      debugPrint('  Current time: $now');
      debugPrint('  Scheduled time: $scheduledDate');
      debugPrint('  Duration: $value $unit');

      await _notifications.zonedSchedule(
        id,
        'Time to text $name!',
        'Mindlyy: Keep the connection alive',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'mindlyy_reminders',
            'Reminders',
            channelDescription: 'Friendship reminders',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('Notification scheduled successfully!');

      // Verify the notification was scheduled
      final pendingNotifications =
          await _notifications.pendingNotificationRequests();
      debugPrint('Total pending notifications: ${pendingNotifications.length}');
    } catch (e, stackTrace) {
      debugPrint('ERROR scheduling notification: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Cancel a specific notification
  static Future<void> cancel(String stringId) async {
    final id = stringId.hashCode & 0x7fffffff;
    debugPrint('Cancelling notification with ID: $id');
    await _notifications.cancel(id);
  }

  /// Show an instant test notification
  static Future<void> showInstantNotification() async {
    try {
      debugPrint('Showing test notification...');

      const androidDetails = AndroidNotificationDetails(
        'mindlyy_test',
        'Test Notifications',
        channelDescription: 'Test notifications',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notifications.show(
        999,
        'Mindlyy Test',
        'If you see this, notifications are working!',
        notificationDetails,
      );

      debugPrint('Test notification sent successfully!');
    } catch (e) {
      debugPrint('ERROR showing test notification: $e');
    }
  }

  /// Check if permissions are granted
  static Future<bool> arePermissionsGranted() async {
    if (Platform.isAndroid) {
      final notifStatus = await Permission.notification.status;
      final alarmStatus = await Permission.scheduleExactAlarm.status;
      debugPrint('Notification permission: $notifStatus');
      debugPrint('Exact alarm permission: $alarmStatus');
      return notifStatus.isGranted && alarmStatus.isGranted;
    }
    return true;
  }
}
