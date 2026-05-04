import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_overview.dart';
import 'package:mobile_orvexis/feature/payroll/domain/repositories/payroll_repository.dart';

class GetPayrollOverviewUseCase {
  const GetPayrollOverviewUseCase(this._repository);

  final PayrollRepository _repository;

  Future<PayrollOverview> call({required String organizationId}) {
    return _repository.getOverview(organizationId: organizationId);
  }
}
