import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_history_item.dart';
import 'package:mobile_orvexis/feature/payroll/domain/repositories/payroll_repository.dart';

class GetPayrollHistoryUseCase {
  const GetPayrollHistoryUseCase(this._repository);

  final PayrollRepository _repository;

  Future<List<PayrollHistoryItem>> call({required String organizationId}) {
    return _repository.getPayrollHistory(organizationId: organizationId);
  }
}
