import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/employee_filter.dart';
import 'package:mobile_orvexis/feature/employees/presentation/widgets/employees_screen/employees_filter_chip.dart';

class EmployeesFilterBar extends StatelessWidget {
  const EmployeesFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final EmployeeFilter selectedFilter;
  final ValueChanged<EmployeeFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        EmployeesFilterChip(
          label: 'Todos',
          selected: selectedFilter == EmployeeFilter.all,
          onTap: () => onFilterSelected(EmployeeFilter.all),
        ),
        const SizedBox(width: 10),
        EmployeesFilterChip(
          label: 'Activos',
          selected: selectedFilter == EmployeeFilter.active,
          onTap: () => onFilterSelected(EmployeeFilter.active),
        ),
        const SizedBox(width: 10),
        EmployeesFilterChip(
          label: 'Inactivos',
          selected: selectedFilter == EmployeeFilter.inactive,
          onTap: () => onFilterSelected(EmployeeFilter.inactive),
        ),
      ],
    );
  }
}
