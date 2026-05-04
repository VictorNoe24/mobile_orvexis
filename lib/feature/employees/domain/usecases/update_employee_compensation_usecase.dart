import 'package:mobile_orvexis/feature/employees/domain/entities/update_employee_compensation_input.dart';
import 'package:mobile_orvexis/feature/employees/domain/repositories/employees_repository.dart';

class UpdateEmployeeCompensationUseCase {
  const UpdateEmployeeCompensationUseCase(this._repository);

  final EmployeesRepository _repository;

  Future<void> call({
    required String organizationId,
    required String employeeId,
    required UpdateEmployeeCompensationInput input,
  }) {
    return _repository.updateEmployeeCompensation(
      organizationId: organizationId,
      employeeId: employeeId,
      input: input,
    );
  }
}
