import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_report_data.dart';
import 'package:mobile_orvexis/feature/payroll/domain/usecases/get_payroll_report_usecase.dart';

class PayrollRunDetailController extends ChangeNotifier {
  PayrollRunDetailController(
    this._getCurrentSessionUseCase,
    this._getPayrollReportUseCase,
  );

  final GetCurrentSessionUseCase _getCurrentSessionUseCase;
  final GetPayrollReportUseCase _getPayrollReportUseCase;

  bool isLoading = false;
  String? errorMessage;
  PayrollReportData? report;
  bool _isDisposed = false;

  Future<void> load(String runId) async {
    if (_isDisposed) return;

    isLoading = true;
    errorMessage = null;
    _notifySafely();

    try {
      final session = await _getCurrentSessionUseCase();
      if (session == null) {
        throw Exception('No se encontró una sesión activa.');
      }

      report = await _getPayrollReportUseCase(
        organizationId: session.organizationId,
        runId: runId,
      );
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      _notifySafely();
    }
  }

  void _notifySafely() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
