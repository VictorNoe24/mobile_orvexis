import 'package:mobile_orvexis/feature/employees/domain/entities/employee_filter.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/employees_page.dart';
import 'package:mobile_orvexis/feature/employees/domain/repositories/employees_repository.dart';

class GetEmployeesUseCase {
  const GetEmployeesUseCase(this._repository);

  final EmployeesRepository _repository;

  Future<EmployeesPage> call({
    required String organizationId,
    required String query,
    required EmployeeFilter filter,
    required int page,
    required int pageSize,
  }) {
    return _repository.getEmployees(
      organizationId: organizationId,
      query: query,
      filter: filter,
      page: page,
      pageSize: pageSize,
    );
  }
}
