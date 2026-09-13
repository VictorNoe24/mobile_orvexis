import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_payment_preview.dart';
import 'package:mobile_orvexis/feature/payroll/domain/repositories/payroll_repository.dart';

class GetPayrollPaymentPreviewUseCase {
  const GetPayrollPaymentPreviewUseCase(this._repository);

  final PayrollRepository _repository;

  Future<PayrollPaymentPreview> call({
    required String organizationId,
    required String payFrequency,
    String? projectId,
  }) {
    return _repository.getPaymentPreview(
      organizationId: organizationId,
      payFrequency: payFrequency,
      projectId: projectId,
    );
  }
}
