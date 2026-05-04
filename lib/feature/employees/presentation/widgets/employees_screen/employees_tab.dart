import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_orvexis/feature/employees/presentation/providers/employees_controller.dart';
import 'package:mobile_orvexis/feature/employees/presentation/widgets/employees_screen/employee_list_card.dart';
import 'package:mobile_orvexis/feature/employees/presentation/widgets/employees_screen/employees_empty_state.dart';
import 'package:mobile_orvexis/feature/employees/presentation/widgets/employees_screen/employees_filter_bar.dart';
import 'package:mobile_orvexis/feature/employees/presentation/widgets/employees_screen/employees_loading_more.dart';
import 'package:mobile_orvexis/feature/employees/presentation/widgets/employees_screen/employees_search_field.dart';

class EmployeesTab extends StatelessWidget {
  const EmployeesTab({super.key, required this.controller});

  final EmployeesController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.isInitialLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage != null && controller.employees.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                controller.errorMessage!,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView(
          controller: controller.scrollController,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          children: [
            EmployeesSearchField(controller: controller.searchController),
            const SizedBox(height: 18),
            EmployeesFilterBar(
              selectedFilter: controller.selectedFilter,
              onFilterSelected: controller.selectFilter,
            ),
            const SizedBox(height: 16),
            if (controller.employees.isEmpty)
              const EmployeesEmptyState()
            else ...[
              ...controller.employees.map(
                (employee) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EmployeeListCard(
                    employee: employee,
                    onTap: () async {
                      final didUpdate = await context.push<bool>(
                        '/employees/${employee.id}/edit',
                      );
                      if (didUpdate == true) {
                        await controller.refresh();
                      }
                    },
                  ),
                ),
              ),
              if (controller.isLoadingMore) const EmployeesLoadingMore(),
            ],
          ],
        );
      },
    );
  }
}
