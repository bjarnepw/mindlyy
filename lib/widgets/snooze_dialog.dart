import 'package:flutter/material.dart';

class SnoozeDialog extends StatefulWidget {
  final String name;
  const SnoozeDialog({super.key, required this.name});

  @override
  State<SnoozeDialog> createState() => _SnoozeDialogState();
}

class _SnoozeDialogState extends State<SnoozeDialog> {
  int _selectedMinutes = 15;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Snooze ${widget.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Remind me again in:'),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _selectedMinutes,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: [5, 15, 30, 60].map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('$value Minutes'),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedMinutes = val!),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, {'value': _selectedMinutes, 'unit': 'minutes'}),
          child: const Text('Snooze'),
        ),
      ],
    );
  }
}