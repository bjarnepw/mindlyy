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
  List<Contact>? _filteredContacts;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() async {
    if (await FlutterContacts.requestPermission()) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        _contacts = contacts;
        _filteredContacts = contacts;
      });
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    } else {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
  }

  void _filterContacts(String query) {
    final filtered = _contacts!
        .where((c) => c.displayName.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      _searchQuery = query;
      _filteredContacts = filtered;
    });
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
      appBar: AppBar(
        title: const Text('Choose Friend'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: _filterContacts,
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _contacts == null
          ? const Center(child: CircularProgressIndicator())
          : _filteredContacts!.isEmpty
          ? const Center(child: Text('No contacts found'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _filteredContacts!.length,
              itemBuilder: (context, i) {
                final contact = _filteredContacts![i];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading:
                        (contact.photo != null && contact.photo!.isNotEmpty)
                        ? CircleAvatar(
                            backgroundImage: MemoryImage(contact.photo!),
                          )
                        : CircleAvatar(
                            child: Text(_getInitials(contact.displayName)),
                          ),
                    title: Text(contact.displayName),
                    subtitle: contact.phones.isNotEmpty
                        ? Text(contact.phones.first.number)
                        : null,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _addReminder(contact),
                  ),
                );
              },
            ),
    );
  }
}
