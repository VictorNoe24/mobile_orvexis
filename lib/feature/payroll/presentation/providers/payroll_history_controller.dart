import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_history_item.dart';
import 'package:mobile_orvexis/feature/payroll/domain/usecases/get_payroll_history_usecase.dart';

class PayrollHistoryController extends ChangeNotifier {
  PayrollHistoryController(
    this._getCurrentSessionUseCase,
    this._getPayrollHistoryUseCase,
  );

  final GetCurrentSessionUseCase _getCurrentSessionUseCase;
  final GetPayrollHistoryUseCase _getPayrollHistoryUseCase;

  bool isLoading = false;
  String? errorMessage;
  List<PayrollHistoryItem> items = const [];
  bool _isDisposed = false;

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
