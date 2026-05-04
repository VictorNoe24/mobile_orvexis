import 'package:mobile_orvexis/feature/employees/domain/entities/create_employee_input.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/employee_form_data.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/employee_filter.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/employees_page.dart';
import 'package:mobile_orvexis/feature/employees/domain/repositories/employees_repository.dart';
import 'package:mobile_orvexis/feature/employees/infrastructure/datasources/employees_local_datasource.dart';

class EmployeesRepositoryImpl implements EmployeesRepository {
  const EmployeesRepositoryImpl(this._dataSource);

  final EmployeesLocalDataSource _dataSource;

  @override
  Future<List<String>> getRoleNames({
    required String organizationId,
  }) {
    return _dataSource.getRoleNames(organizationId: organizationId);
  }

  @override
  Future<EmployeeFormData> getEmployeeById({
    required String organizationId,
    required String employeeId,
  }) {
    return _dataSource.getEmployeeById(
      organizationId: organizationId,
      employeeId: employeeId,
    );
  }

  @override
  Future<EmployeesPage> getEmployees({
    required String organizationId,
    required String query,
    required EmployeeFilter filter,
    required int page,
    required int pageSize,
  }) {
    return _dataSource.getEmployees(
      organizationId: organizationId,
      query: query,
      filter: filter,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<void> createEmployee({
    required String organizationId,
    required CreateEmployeeInput input,
  }) {
    return _dataSource.createEmployee(
      organizationId: organizationId,
      input: input,
    );
  }

  @override
  Future<void> updateEmployee({
    required String organizationId,
    required String employeeId,
    required CreateEmployeeInput input,
  }) {
    return _dataSource.updateEmployee(
      organizationId: organizationId,
      employeeId: employeeId,
      input: input,
    );
  }
}
