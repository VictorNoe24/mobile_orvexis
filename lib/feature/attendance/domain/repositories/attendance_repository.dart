import 'package:mobile_orvexis/feature/attendance/domain/entities/attendance_employee.dart';
import 'package:mobile_orvexis/feature/attendance/domain/entities/attendance_entry_input.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceEmployee>> getDailyAttendance({
    required String organizationId,
    required String projectId,
    required DateTime workDate,
  });

  Future<void> saveDailyAttendance({
    required String organizationId,
    required String projectId,
    required DateTime workDate,
    required List<AttendanceEntryInput> entries,
  });
}
