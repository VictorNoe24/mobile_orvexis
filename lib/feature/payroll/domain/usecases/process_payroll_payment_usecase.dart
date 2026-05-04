import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_payment_adjustment_input.dart';
import 'package:mobile_orvexis/feature/payroll/domain/repositories/payroll_repository.dart';

class ProcessPayrollPaymentUseCase {
  const ProcessPayrollPaymentUseCase(this._repository);

  final PayrollRepository _repository;

  Future<void> call({
    required String organizationId,
    required String payFrequency,
    required List<PayrollPaymentAdjustmentInput> adjustments,
  }) {
    return _repository.processPayment(
      organizationId: organizationId,
      payFrequency: payFrequency,
      adjustments: adjustments,
    );
  }
}
