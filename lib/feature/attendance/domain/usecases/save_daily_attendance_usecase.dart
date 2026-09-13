import 'package:mobile_orvexis/feature/attendance/domain/entities/attendance_entry_input.dart';
import 'package:mobile_orvexis/feature/attendance/domain/repositories/attendance_repository.dart';

class SaveDailyAttendanceUseCase {
  const SaveDailyAttendanceUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<void> call({
    required String organizationId,
    required String projectId,
    required DateTime workDate,
    required List<AttendanceEntryInput> entries,
  }) => _repository.saveDailyAttendance(
    organizationId: organizationId,
    projectId: projectId,
    workDate: workDate,
    entries: entries,
  );
}
