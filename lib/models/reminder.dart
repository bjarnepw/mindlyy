
class ContactReminder {
  final String id;
  final String displayName;
  final String phoneNumber;
  DateTime lastTexted;
  final int intervalValue;
  final String intervalUnit;
  List<DateTime> history;

  ContactReminder({
    required this.id,
    required this.displayName,
    required this.phoneNumber,
    required this.lastTexted,
    required this.intervalValue,
    required this.intervalUnit,
    required this.history,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': displayName,
    'phone': phoneNumber,
    'last': lastTexted.toIso8601String(),
    'val': intervalValue,
    'unit': intervalUnit,
    'history': history.map((e) => e.toIso8601String()).toList(),
  };

  factory ContactReminder.fromMap(Map<String, dynamic> map) => ContactReminder(
    id: map['id'],
    displayName: map['name'],
    phoneNumber: map['phone'],
    lastTexted: DateTime.parse(map['last']),
    intervalValue: map['val'],
    intervalUnit: map['unit'],
    history: (map['history'] as List? ?? [])
        .map((e) => DateTime.parse(e))
        .toList(),
  );
}
