import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_payment_adjustment_input.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_payment_preview.dart';
import 'package:mobile_orvexis/feature/payroll/domain/usecases/get_payroll_payment_preview_usecase.dart';
import 'package:mobile_orvexis/feature/payroll/domain/usecases/process_payroll_payment_usecase.dart';

class PayrollPaymentController extends ChangeNotifier {
  PayrollPaymentController(
    this._getCurrentSessionUseCase,
    this._getPayrollPaymentPreviewUseCase,
    this._processPayrollPaymentUseCase,
  );

  final GetCurrentSessionUseCase _getCurrentSessionUseCase;
  final GetPayrollPaymentPreviewUseCase _getPayrollPaymentPreviewUseCase;
  final ProcessPayrollPaymentUseCase _processPayrollPaymentUseCase;

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  PayrollPaymentPreview? preview;
  bool _isDisposed = false;

  Future<void> initialize(String payFrequency) async {
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

      preview = await _getPayrollPaymentPreviewUseCase(
        organizationId: session.organizationId,
        payFrequency: payFrequency,
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

  Future<void> submit(String payFrequency) async {
    await submitWithAdjustments(
      payFrequency: payFrequency,
      adjustments: const [],
    );
  }

  Future<void> submitWithAdjustments({
    required String payFrequency,
    required List<PayrollPaymentAdjustmentInput> adjustments,
  }) async {
    if (_isDisposed) {
      return;
    }

    isSaving = true;
    _notifySafely();

    try {
      final session = await _getCurrentSessionUseCase();
      if (_isDisposed) {
        return;
      }

      if (session == null) {
        throw Exception('No se encontro una sesion activa.');
      }

      await _processPayrollPaymentUseCase(
        organizationId: session.organizationId,
        payFrequency: payFrequency,
        adjustments: adjustments,
      );
    } finally {
      if (!_isDisposed) {
        isSaving = false;
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
