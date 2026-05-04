import 'package:mobile_orvexis/feature/employees/domain/entities/create_employee_input.dart';
import 'package:mobile_orvexis/feature/employees/domain/repositories/employees_repository.dart';

class UpdateEmployeeUseCase {
  const UpdateEmployeeUseCase(this._repository);

  final EmployeesRepository _repository;

  Future<void> call({
    required String organizationId,
    required String employeeId,
    required CreateEmployeeInput input,
  }) {
    return _repository.updateEmployee(
      organizationId: organizationId,
      employeeId: employeeId,
      input: input,
    );
  }
}
