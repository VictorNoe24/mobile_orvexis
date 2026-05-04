import 'package:mobile_orvexis/feature/employees/domain/entities/employee.dart';

class EmployeesPage {
  const EmployeesPage({
    required this.items,
    required this.hasMore,
  });

  final List<Employee> items;
  final bool hasMore;
}
