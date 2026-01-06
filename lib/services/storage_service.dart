import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder.dart';

class StorageService {
  static const String _key = 'mindlyy_data';

  static Future<void> saveReminders(List<ContactReminder> list) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(list.map((e) => e.toMap()).toList());
    await prefs.setString(_key, encoded);
  }

  static Future<List<ContactReminder>> getReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return decoded.map((e) => ContactReminder.fromMap(e)).toList();
  }
}
