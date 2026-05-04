import 'package:mobile_orvexis/feature/employees/domain/repositories/employees_repository.dart';

class GetEmployeeRoleNamesUseCase {
  const GetEmployeeRoleNamesUseCase(this._repository);

  final EmployeesRepository _repository;

  Future<List<String>> call({required String organizationId}) {
    return _repository.getRoleNames(organizationId: organizationId);
  }
}
