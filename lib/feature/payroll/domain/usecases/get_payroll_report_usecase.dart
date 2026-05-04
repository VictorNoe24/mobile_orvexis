import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_report_data.dart';
import 'package:mobile_orvexis/feature/payroll/domain/repositories/payroll_repository.dart';

class GetPayrollReportUseCase {
  const GetPayrollReportUseCase(this._repository);

  final PayrollRepository _repository;

  Future<PayrollReportData> call({
    required String organizationId,
    required String runId,
  }) {
    return _repository.getPayrollReport(
      organizationId: organizationId,
      runId: runId,
    );
  }
}
