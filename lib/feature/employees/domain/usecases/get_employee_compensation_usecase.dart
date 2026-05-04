import 'package:mobile_orvexis/feature/employees/domain/entities/employee_compensation_form_data.dart';
import 'package:mobile_orvexis/feature/employees/domain/repositories/employees_repository.dart';

class GetEmployeeCompensationUseCase {
  const GetEmployeeCompensationUseCase(this._repository);

  final EmployeesRepository _repository;

  Future<EmployeeCompensationFormData> call({
    required String organizationId,
    required String employeeId,
  }) {
    return _repository.getEmployeeCompensation(
      organizationId: organizationId,
      employeeId: employeeId,
    );
  }
}
