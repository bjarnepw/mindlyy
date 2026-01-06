import 'package:flutter/material.dart';

class SnoozeDialog extends StatefulWidget {
  final String name;
  const SnoozeDialog({super.key, required this.name});

  @override
  State<SnoozeDialog> createState() => _SnoozeDialogState();
}

class _SnoozeDialogState extends State<SnoozeDialog> {
  int _minutes = 15;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Snooze ${widget.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Remind me again in:'),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: _minutes,
            items: [5, 15, 30, 60]
                .map(
                  (v) => DropdownMenuItem(value: v, child: Text('$v Minutes')),
                )
                .toList(),
            onChanged: (val) => setState(() => _minutes = val!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, {'value': _minutes, 'unit': 'minutes'}),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
