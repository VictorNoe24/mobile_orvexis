class AttendanceEmployee {
  const AttendanceEmployee({
    required this.orgUserId,
    required this.name,
    required this.initials,
    this.checkInAt,
    this.checkOutAt,
    this.minutesWorked,
    this.notes,
  });

  final String orgUserId;
  final String name;
  final String initials;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final int? minutesWorked;
  final String? notes;
}
