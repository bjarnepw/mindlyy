import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones(); // Required for zonedSchedule
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    await _notifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // Request notification permission on startup
    await requestPermission();
  }

  static Future<void> requestPermission() async {
    if (Platform.isIOS) {
      // iOS/macOS
      final iosDetails = await _notifications
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (iosDetails == false) print("iOS notifications denied");
    } else if (Platform.isAndroid) {
      // Android 13+ needs explicit POST_NOTIFICATIONS permission
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final result = await Permission.notification.request();
        if (!result.isGranted) print("Android notifications denied");
      }
    }
  }

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

    final int notificationId = stringId.hashCode.abs() % 2147483647;

    await _notifications.zonedSchedule(
      notificationId,
      'Text $name',
      'Mindlyy: Time to reconnect! ✨',
      tz.TZDateTime.now(tz.local).add(duration),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mindlyy_reminders',
          'Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancel(String stringId) async {
    await _notifications.cancel(stringId.hashCode.abs() % 2147483647);
  }
}
