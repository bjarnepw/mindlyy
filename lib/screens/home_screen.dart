import 'dart:async';
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
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _load();

    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
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

  String _getTimeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays > 0) return '${duration.inDays}d ago';
    if (duration.inHours > 0) return '${duration.inHours}h ago';
    if (duration.inMinutes > 0) return '${duration.inMinutes}m ago';
    return 'Just now';
  }

  void _showSnoozeDialog(ContactReminder r) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remind me later'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How long should we wait?'),
            const SizedBox(height: 10),
            // Re-using a simplified version of your ReminderDialog
            DropdownButton<int>(
              value: 15, // Default 15 mins
              items: [5, 15, 30, 60].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value Minutes'),
                );
              }).toList(),
              onChanged: (val) {
                Navigator.pop(context, {'value': val, 'unit': 'minutes'});
              },
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await NotificationService.cancel(r.id);
      await NotificationService.scheduleReminder(
        r.displayName,
        result['value'],
        result['unit'],
        r.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Snoozed ${r.displayName} for ${result['value']} mins',
            ),
          ),
        );
      }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notification_important_outlined),
            tooltip: 'Test Notification',
            onPressed: () async {
              await NotificationService.showInstantNotification();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test notification sent! Check your tray.'),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.person_add),
            tooltip: 'Add person from contacts',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactPickerScreen()),
              );
              _load();
            },
          ),
        ],
      ),
      body: _reminders.isEmpty
          ? const Center(child: Text('Add a friend to start!'))
          : ListView.builder(
              itemCount: _reminders.length,
              itemBuilder: (context, i) {
                final r = _reminders[i];
                return Dismissible(
                  key: Key(r.id),
                  // LEFT TO RIGHT -> DELETE (Red)
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  // RIGHT TO LEFT -> CONTACTED (Green)
                  secondaryBackground: Container(
                    color: Colors.green,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      _logInteraction(r);
                      return false; // Don't remove item from list
                    } else {
                      // Logic for Delete
                      setState(() => _reminders.removeAt(i));
                      StorageService.saveReminders(_reminders);
                      NotificationService.cancel(r.id);
                      return true;
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(r.displayName),
                      subtitle: Text(
                        'Last: ${_getTimeAgo(r.lastTexted)} • Every ${r.intervalValue} ${r.intervalUnit}',
                      ),
                    ),
                  ),
                );
              },
            ),
      /*floatingActionButton: FloatingActionButton.extended(
        onPressed: ()
          _load();
        },
        label: const Text('Add Friend'),
        icon: const Icon(Icons.person_add),
      ),*/
    );
  }
}
