import 'package:flutter/material.dart';
import 'package:mindlyy/screens/nav_page.dart';

class ReminderDialog extends StatefulWidget {
  final String name;
  const ReminderDialog({super.key, required this.name});

  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  int _val = 1;
  String _unit = 'days';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Text ${widget.name} every...'),
      content: Row(
        children: [
          Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Qty'),
              onChanged: (v) => _val = int.tryParse(v) ?? 1,
            ),
          ),
          const SizedBox(width: 10),
          DropdownButton<String>(
            value: _unit,
            items: [
              'minutes',
              'hours',
              'days',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _unit = v!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NavPage()),
          ),
          child: const Text('Set'),
        ),
      ],
    );
  }
}
