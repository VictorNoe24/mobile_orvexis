import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_overview.dart';
import 'package:mobile_orvexis/feature/payroll/domain/usecases/get_payroll_overview_usecase.dart';

class PayrollController extends ChangeNotifier {
  PayrollController(
    this._getCurrentSessionUseCase,
    this._getPayrollOverviewUseCase,
  );

  final GetCurrentSessionUseCase _getCurrentSessionUseCase;
  final GetPayrollOverviewUseCase _getPayrollOverviewUseCase;

  bool isLoading = false;
  String? errorMessage;
  PayrollOverview? overview;
  bool _isDisposed = false;

  Future<void> initialize() async {
    await refresh();
  }

  Future<void> refresh() async {
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

      overview = await _getPayrollOverviewUseCase(
        organizationId: session.organizationId,
      );
      if (_isDisposed) {
        return;
      }
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
