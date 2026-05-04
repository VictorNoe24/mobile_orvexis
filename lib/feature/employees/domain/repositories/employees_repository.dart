import 'package:mobile_orvexis/feature/employees/domain/entities/create_employee_input.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/employee_form_data.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/employee_filter.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/employees_page.dart';

abstract class EmployeesRepository {
  Future<List<String>> getRoleNames({
    required String organizationId,
  });

  Future<EmployeeFormData> getEmployeeById({
    required String organizationId,
    required String employeeId,
  });

  Future<EmployeesPage> getEmployees({
    required String organizationId,
    required String query,
    required EmployeeFilter filter,
    required int page,
    required int pageSize,
  });

  Future<void> createEmployee({
    required String organizationId,
    required CreateEmployeeInput input,
  });

  Future<void> updateEmployee({
    required String organizationId,
    required String employeeId,
    required CreateEmployeeInput input,
  });
}
