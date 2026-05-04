import 'package:mobile_orvexis/feature/employees/domain/entities/employee_form_data.dart';
import 'package:mobile_orvexis/feature/employees/domain/repositories/employees_repository.dart';

class GetEmployeeByIdUseCase {
  const GetEmployeeByIdUseCase(this._repository);

  final EmployeesRepository _repository;

  Future<EmployeeFormData> call({
    required String organizationId,
    required String employeeId,
  }) {
    return _repository.getEmployeeById(
      organizationId: organizationId,
      employeeId: employeeId,
    );
  }
}
