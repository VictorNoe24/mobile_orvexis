import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/attendance/domain/entities/attendance_employee.dart';
import 'package:mobile_orvexis/feature/attendance/domain/entities/attendance_entry_input.dart';
import 'package:mobile_orvexis/feature/attendance/domain/usecases/get_daily_attendance_usecase.dart';
import 'package:mobile_orvexis/feature/attendance/domain/usecases/save_daily_attendance_usecase.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';

class AttendanceController extends ChangeNotifier {
  AttendanceController(
    this._getCurrentSessionUseCase,
    this._getDailyAttendance,
    this._saveDailyAttendance,
  );

  final GetCurrentSessionUseCase _getCurrentSessionUseCase;
  final GetDailyAttendanceUseCase _getDailyAttendance;
  final SaveDailyAttendanceUseCase _saveDailyAttendance;

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  List<AttendanceEmployee> employees = const [];
  bool _isDisposed = false;

  Future<void> load({
    required String projectId,
    required DateTime workDate,
  }) async {
    isLoading = true;
    errorMessage = null;
    _notify();
    try {
      final session = await _getCurrentSessionUseCase();
      if (session == null) throw Exception('No se encontró una sesión activa.');
      employees = await _getDailyAttendance(
        organizationId: session.organizationId,
        projectId: projectId,
        workDate: workDate,
      );
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      _notify();
    }
  }

  Future<void> save({
    required String projectId,
    required DateTime workDate,
    required List<AttendanceEntryInput> entries,
  }) async {
    isSaving = true;
    _notify();
    try {
      final session = await _getCurrentSessionUseCase();
      if (session == null) throw Exception('No se encontró una sesión activa.');
      await _saveDailyAttendance(
        organizationId: session.organizationId,
        projectId: projectId,
        workDate: workDate,
        entries: entries,
      );
    } finally {
      isSaving = false;
      _notify();
    }
  }

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
