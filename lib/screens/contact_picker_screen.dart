import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:uuid/uuid.dart';
import '../models/reminder.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../widgets/reminder_dialog.dart';

class ContactPickerScreen extends StatefulWidget {
  const ContactPickerScreen({super.key});

  @override
  State<ContactPickerScreen> createState() => _ContactPickerScreenState();
}

class _ContactPickerScreenState extends State<ContactPickerScreen> {
  List<Contact>? _contacts;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() async {
    if (await FlutterContacts.requestPermission()) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      setState(() => _contacts = contacts);
    }
  }

  void _addReminder(Contact contact) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => ReminderDialog(name: contact.displayName),
    );

    if (result != null) {
      final String newId = const Uuid().v4();
      final reminder = ContactReminder(
        id: newId,
        displayName: contact.displayName,
        phoneNumber: contact.phones.isNotEmpty
            ? contact.phones.first.number
            : '',
        lastTexted: DateTime.now(),
        intervalValue: result['value'],
        intervalUnit: result['unit'],
        history: [],
      );

      final current = await StorageService.getReminders();
      current.add(reminder);
      await StorageService.saveReminders(current);
      await NotificationService.scheduleReminder(
        reminder.displayName,
        reminder.intervalValue,
        reminder.intervalUnit,
        newId,
      );
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Friend')),
      body: _contacts == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _contacts!.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(_contacts![i].displayName),
                onTap: () => _addReminder(_contacts![i]),
              ),
            ),
    );
  }
}
