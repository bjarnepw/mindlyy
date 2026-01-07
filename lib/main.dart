import 'package:flutter/material.dart';
import 'package:mindlyy/screens/nav_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'package:dynamic_color/dynamic_color.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  // Request permission if not granted
  await Permission.scheduleExactAlarm.request();
  await Permission.notification.request();

  runApp(const MindlyyApp());
}

class MindlyyApp extends StatelessWidget {
  const MindlyyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        // Fallback color schemes if dynamic color not available
        final lightScheme =
            lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.blue);
        final darkScheme =
            darkDynamic ??
            ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            );

        return MaterialApp(
          title: 'Mindlyy',
          theme: ThemeData(colorScheme: lightScheme, useMaterial3: true),
          darkTheme: ThemeData(colorScheme: darkScheme, useMaterial3: true),
          themeMode: ThemeMode.system, // follows Android system theme
          home: const NavPage(),
        );
      },
    );
  }
}
