import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_assigned_employee.dart';
import 'package:mobile_orvexis/feature/projects/presentation/providers/project_detail_controller.dart';

class ProjectAssignedEmployeesScreen extends StatefulWidget {
  const ProjectAssignedEmployeesScreen({
    super.key,
    required this.projectId,
    required this.controller,
  });

  final String projectId;
  final ProjectDetailController controller;

  @override
  State<ProjectAssignedEmployeesScreen> createState() =>
      _ProjectAssignedEmployeesScreenState();
}

class _ProjectAssignedEmployeesScreenState
    extends State<ProjectAssignedEmployeesScreen> {
  bool _didMutateAssignments = false;

  @override
  void initState() {
    super.initState();
    widget.controller.load(widget.projectId);
  }

  @override
  void didUpdateWidget(covariant ProjectAssignedEmployeesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.projectId != widget.projectId) {
      widget.controller.load(widget.projectId);
    }
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  Future<void> _handleRemoveAssignedEmployee(
    ProjectAssignedEmployee employee,
  ) async {
    final shouldRemove =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Dar de baja de la obra'),
            content: Text('¿Quieres quitar a ${employee.name} de esta obra?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Quitar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!mounted || !shouldRemove) {
      return;
    }

    try {
      _didMutateAssignments = true;
      await widget.controller.removeAssignedEmployee(
        projectId: widget.projectId,
        assignmentId: employee.assignmentId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empleado dado de baja de la obra.')),
      );
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
        final detail = widget.controller.detail;
        final employees = widget.controller.assignedEmployees;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Personal asignado'),
            leading: IconButton(
              onPressed: () => context.pop(_didMutateAssignments),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          body: widget.controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : widget.controller.errorMessage != null || detail == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      widget.controller.errorMessage ??
                          'No se pudo cargar el personal asignado.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.name,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${employees.length} empleados activos en esta obra',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: employees.isEmpty
                            ? const _EmptyAssignedEmployeesState()
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  12,
                                  16,
                                  24,
                                ),
                                itemCount: employees.length,
                                itemBuilder: (context, index) {
                                  final employee = employees[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _AssignedEmployeeTile(
                                      employee: employee,
                                      onRemove:
                                          widget
                                              .controller
                                              .isMutatingAssignments
                                          ? null
                                          : () => _handleRemoveAssignedEmployee(
                                              employee,
                                            ),
                                    ),
                                  );
                                },
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

class _AssignedEmployeeTile extends StatelessWidget {
  const _AssignedEmployeeTile({required this.employee, required this.onRemove});

  final ProjectAssignedEmployee employee;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colors.primary.withValues(alpha: 0.14),
            child: Text(
              employee.initials,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.primary,
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
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  employee.role,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Asignado ${employee.assignedLabel}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            tooltip: 'Quitar de la obra',
            icon: Icon(
              Icons.person_remove_alt_1_rounded,
              color: onRemove == null ? colors.outline : colors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAssignedEmployeesState extends StatelessWidget {
  const _EmptyAssignedEmployeesState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.groups_rounded, size: 42, color: colors.primary),
            const SizedBox(height: 12),
            Text(
              'Aún no hay personal asignado a esta obra.',
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
