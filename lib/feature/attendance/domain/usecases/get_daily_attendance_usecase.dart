import 'package:mobile_orvexis/feature/attendance/domain/entities/attendance_employee.dart';
import 'package:mobile_orvexis/feature/attendance/domain/repositories/attendance_repository.dart';

class GetDailyAttendanceUseCase {
  const GetDailyAttendanceUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<List<AttendanceEmployee>> call({
    required String organizationId,
    required String projectId,
    required DateTime workDate,
  }) => _repository.getDailyAttendance(
    organizationId: organizationId,
    projectId: projectId,
    workDate: workDate,
  );
}
