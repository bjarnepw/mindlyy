import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import 'contact_picker_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ContactReminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final data = await StorageService.getReminders();
    setState(() => _reminders = data);
  }

  void _logInteraction(ContactReminder r) async {
    setState(() {
      r.lastTexted = DateTime.now();
      r.history.add(DateTime.now());
    });
    await StorageService.saveReminders(_reminders);
    await NotificationService.cancel(r.id);
    await NotificationService.scheduleReminder(
      r.displayName,
      r.intervalValue,
      r.intervalUnit,
      r.id,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logged! Reminding you again in ${r.intervalValue} ${r.intervalUnit}.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mindlyy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _reminders.isEmpty
          ? const Center(child: Text('Add a friend to start!'))
          : ListView.builder(
              itemCount: _reminders.length,
              itemBuilder: (context, i) {
                final r = _reminders[i];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(r.displayName),
                    subtitle: Text(
                      'Frequency: ${r.intervalValue} ${r.intervalUnit}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () => _logInteraction(r),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ContactPickerScreen()),
          );
          _load();
        },
        label: const Text('Add Friend'),
        icon: const Icon(Icons.person_add),
      ),
    );
  }
}
