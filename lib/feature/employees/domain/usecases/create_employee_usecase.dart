import 'package:mobile_orvexis/feature/employees/domain/entities/create_employee_input.dart';
import 'package:mobile_orvexis/feature/employees/domain/repositories/employees_repository.dart';

class CreateEmployeeUseCase {
  const CreateEmployeeUseCase(this._repository);

  final EmployeesRepository _repository;

  Future<void> call({
    required String organizationId,
    required CreateEmployeeInput input,
  }) {
    return _repository.createEmployee(
      organizationId: organizationId,
      input: input,
    );
  }
}
