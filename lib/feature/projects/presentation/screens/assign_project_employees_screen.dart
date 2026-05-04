import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_assignable_employee.dart';
import 'package:mobile_orvexis/feature/projects/presentation/providers/assign_project_employees_controller.dart';

class AssignProjectEmployeesScreen extends StatefulWidget {
  const AssignProjectEmployeesScreen({
    super.key,
    required this.projectId,
    required this.controller,
  });

  final String projectId;
  final AssignProjectEmployeesController controller;

  @override
  State<AssignProjectEmployeesScreen> createState() =>
      _AssignProjectEmployeesScreenState();
}

class _AssignProjectEmployeesScreenState
    extends State<AssignProjectEmployeesScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.initialize(widget.projectId);
  }

  @override
  void didUpdateWidget(covariant AssignProjectEmployeesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.projectId != widget.projectId) {
      widget.controller.initialize(widget.projectId);
    }
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  Future<void> _handleAssign() async {
    try {
      await widget.controller.assign(widget.projectId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empleados asignados correctamente.')),
      );
      context.pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Asignar empleados')),
          body: widget.controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : widget.controller.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      widget.controller.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: widget.controller.availableEmployees.isEmpty
                            ? const _EmptyAssignableEmployeesState()
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  16,
                                ),
                                itemCount:
                                    widget.controller.availableEmployees.length,
                                itemBuilder: (context, index) {
                                  final employee = widget
                                      .controller
                                      .availableEmployees[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _AssignableEmployeeTile(
                                      employee: employee,
                                      selected: widget
                                          .controller
                                          .selectedOrgUserIds
                                          .contains(employee.orgUserId),
                                      onTap: () => widget.controller
                                          .toggleEmployee(employee.orgUserId),
                                    ),
                                  );
                                },
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: ElevatedButton(
                          onPressed: widget.controller.isSaving
                              ? null
                              : _handleAssign,
                          child: Text(
                            widget.controller.isSaving
                                ? 'Asignando...'
                                : 'Asignar seleccionados',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _AssignableEmployeeTile extends StatelessWidget {
  const _AssignableEmployeeTile({
    required this.employee,
    required this.selected,
    required this.onTap,
  });

  final ProjectAssignableEmployee employee;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? colors.primary.withValues(alpha: 0.08)
                : colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? colors.primary : colors.outlineVariant,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: selected
                    ? colors.primary
                    : colors.surfaceContainerHighest,
                child: Text(
                  employee.initials,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: selected ? colors.onPrimary : colors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee.role,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Checkbox(value: selected, onChanged: (_) => onTap()),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyAssignableEmployeesState extends StatelessWidget {
  const _EmptyAssignableEmployeesState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_off_rounded, size: 42, color: colors.primary),
            const SizedBox(height: 12),
            Text(
              'No hay empleados disponibles para asignar.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
