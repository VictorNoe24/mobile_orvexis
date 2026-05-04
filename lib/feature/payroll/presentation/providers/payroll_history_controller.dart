import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_history_item.dart';
import 'package:mobile_orvexis/feature/payroll/domain/usecases/get_payroll_history_usecase.dart';
import 'package:mobile_orvexis/feature/payroll/domain/usecases/get_payroll_report_usecase.dart';
import 'package:mobile_orvexis/feature/payroll/infrastructure/services/payroll_pdf_service.dart';

class PayrollHistoryController extends ChangeNotifier {
  PayrollHistoryController(
    this._getCurrentSessionUseCase,
    this._getPayrollHistoryUseCase,
    this._getPayrollReportUseCase,
    this._payrollPdfService,
  );

  final GetCurrentSessionUseCase _getCurrentSessionUseCase;
  final GetPayrollHistoryUseCase _getPayrollHistoryUseCase;
  final GetPayrollReportUseCase _getPayrollReportUseCase;
  final PayrollPdfService _payrollPdfService;

  bool isLoading = false;
  String? errorMessage;
  List<PayrollHistoryItem> items = const [];
  final Set<String> _exportingRunIds = <String>{};
  bool _isDisposed = false;

  bool isExporting(String runId) => _exportingRunIds.contains(runId);

  Future<void> initialize() async {
    if (_isDisposed) {
      return;
    }

    isLoading = true;
    errorMessage = null;
    _notifySafely();

    try {
      final session = await _getCurrentSessionUseCase();
      if (_isDisposed) {
        return;
      }

      if (session == null) {
        throw Exception('No se encontro una sesion activa.');
      }

      items = await _getPayrollHistoryUseCase(
        organizationId: session.organizationId,
      );
    } catch (error) {
      if (_isDisposed) {
        return;
      }
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      if (!_isDisposed) {
        isLoading = false;
        _notifySafely();
      }
    }
  }

  Future<String> exportReport(String runId) async {
    _exportingRunIds.add(runId);
    _notifySafely();

    try {
      final session = await _getCurrentSessionUseCase();
      if (session == null) {
        throw Exception('No se encontro una sesion activa.');
      }

      final report = await _getPayrollReportUseCase(
        organizationId: session.organizationId,
        runId: runId,
      );

      return _payrollPdfService.generateReport(report);
    } finally {
      _exportingRunIds.remove(runId);
      _notifySafely();
    }
  }

  void _notifySafely() {
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
