import 'package:mobile_orvexis/feature/attendance/domain/entities/attendance_employee.dart';
import 'package:mobile_orvexis/feature/attendance/domain/entities/attendance_entry_input.dart';
import 'package:mobile_orvexis/feature/attendance/domain/repositories/attendance_repository.dart';
import 'package:mobile_orvexis/feature/attendance/infrastructure/datasources/attendance_local_datasource.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  const AttendanceRepositoryImpl(this._localDataSource);

  final AttendanceLocalDataSource _localDataSource;

  @override
  Future<List<AttendanceEmployee>> getDailyAttendance({
    required String organizationId,
    required String projectId,
    required DateTime workDate,
  }) => _localDataSource.getDailyAttendance(
    organizationId: organizationId,
    projectId: projectId,
    workDate: workDate,
  );

  @override
  Future<void> saveDailyAttendance({
    required String organizationId,
    required String projectId,
    required DateTime workDate,
    required List<AttendanceEntryInput> entries,
  }) => _localDataSource.saveDailyAttendance(
    organizationId: organizationId,
    projectId: projectId,
    workDate: workDate,
    entries: entries,
  );
}
