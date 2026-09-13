class AttendanceEntryInput {
  const AttendanceEntryInput({
    required this.orgUserId,
    this.checkInAt,
    this.checkOutAt,
    this.notes,
  });

  final String orgUserId;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final String? notes;
}
