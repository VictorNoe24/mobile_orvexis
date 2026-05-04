import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_activity_item.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_assigned_employee.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_detail.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_item.dart';
import 'package:mobile_orvexis/feature/projects/presentation/providers/project_detail_controller.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    required this.controller,
  });

  final String projectId;
  final ProjectDetailController controller;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  bool _didMutateProject = false;

  @override
  void initState() {
    super.initState();
    widget.controller.load(widget.projectId);
  }

  @override
  void didUpdateWidget(covariant ProjectDetailScreen oldWidget) {
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

  Future<void> _handleAssignEmployees() async {
    final didAssign = await context.push<bool>(
      '/projects/${widget.projectId}/assign-employees',
    );
    if (!mounted || didAssign != true) {
      return;
    }

    _didMutateProject = true;
    await widget.controller.load(widget.projectId);
  }

  Future<void> _handleEditProject() async {
    final didUpdate = await context.push<bool>(
      '/projects/${widget.projectId}/edit',
    );
    if (!mounted || didUpdate != true) {
      return;
    }

    _didMutateProject = true;
    await widget.controller.load(widget.projectId);
  }

  Future<void> _handleViewAllEmployees() async {
    final didMutate = await context.push<bool>(
      '/projects/${widget.projectId}/employees',
    );
    if (!mounted || didMutate != true) {
      return;
    }

    _didMutateProject = true;
    await widget.controller.load(widget.projectId);
  }

  Future<void> _handleViewAllActivities() async {
    await context.push('/projects/${widget.projectId}/activities');
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
      _didMutateProject = true;
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
        if (widget.controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (widget.controller.errorMessage != null ||
            widget.controller.detail == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detalle de obra')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  widget.controller.errorMessage ??
                      'No se pudo cargar la obra.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final detail = widget.controller.detail!;
        final employees = widget.controller.assignedEmployees;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 360,
                leading: IconButton(
                  onPressed: () => context.pop(_didMutateProject),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                title: const Text('Detalle de Obra'),
                actions: [
                  IconButton(
                    onPressed: _handleEditProject,
                    icon: const Icon(Icons.edit_rounded),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _ProjectDetailHero(detail: detail),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProjectProgressCard(detail: detail),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _handleAssignEmployees,
                              icon: const Icon(Icons.person_add_alt_1_rounded),
                              label: const Text('Añadir empleado'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.tonalIcon(
                              onPressed: () {},
                              icon: const Icon(Icons.schedule_rounded),
                              label: const Text('Registrar horas'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _SectionHeader(
                        title: 'Personal Asignado (${employees.length})',
                        actionLabel: employees.isEmpty ? null : 'Ver todos',
                        onActionTap: _handleViewAllEmployees,
                      ),
                      const SizedBox(height: 14),
                      if (employees.isEmpty)
                        const _EmptyAssignedEmployeesCard()
                      else
                        ...employees
                            .take(4)
                            .map(
                              (employee) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _AssignedEmployeeTile(
                                  employee: employee,
                                  onRemove:
                                      widget.controller.isMutatingAssignments
                                      ? null
                                      : () => _handleRemoveAssignedEmployee(
                                          employee,
                                        ),
                                ),
                              ),
                            ),
                      const SizedBox(height: 28),
                      _SectionHeader(
                        title: 'Actividad Reciente',
                        actionLabel: detail.activities.isEmpty
                            ? null
                            : 'Ver todo',
                        onActionTap: _handleViewAllActivities,
                      ),
                      const SizedBox(height: 14),
                      _ProjectActivityTimeline(
                        activities: detail.activities.take(5).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProjectDetailHero extends StatelessWidget {
  const _ProjectDetailHero({required this.detail});

  final ProjectDetail detail;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (detail.imagePath != null && detail.imagePath!.isNotEmpty)
          Image.file(
            File(detail.imagePath!),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const _ProjectDetailHeroFallback(),
          )
        else
          const _ProjectDetailHeroFallback(),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.05),
                Colors.black.withValues(alpha: 0.55),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: IgnorePointer(
            child: Container(
              height: 156,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.28),
                    Colors.white.withValues(alpha: 0.52),
                    Colors.white.withValues(alpha: 0.22),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.30, 0.68, 1.0],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 22,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusHeroBadge(
                label: detail.statusLabel.toUpperCase(),
                status: detail.status,
              ),
              const SizedBox(height: 14),
              Text(
                detail.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      detail.location,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProjectDetailHeroFallback extends StatelessWidget {
  const _ProjectDetailHeroFallback();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary,
            colors.secondary.withValues(alpha: 0.85),
            colors.surfaceContainerHighest,
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(
            Icons.apartment_rounded,
            color: Colors.white,
            size: 44,
          ),
        ),
      ),
    );
  }
}

class _StatusHeroBadge extends StatelessWidget {
  const _StatusHeroBadge({required this.label, required this.status});

  final String label;
  final ProjectStatusCode status;

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: style.foreground,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _ProjectProgressCard extends StatelessWidget {
  const _ProjectProgressCard({required this.detail});

  final ProjectDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Progreso del Proyecto',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${detail.progressPercent}%',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: detail.progressPercent / 100,
              minHeight: 14,
              backgroundColor: colors.surfaceContainerHighest,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _MetricInfo(
                  label: 'INICIO',
                  value: detail.startDateLabel,
                ),
              ),
              Expanded(
                child: _MetricInfo(
                  label: 'FINAL EST.',
                  value: detail.endDateLabel,
                ),
              ),
              Expanded(
                child: _MetricInfo(
                  label: 'PERSONAL',
                  value: '${detail.assignedEmployeesCount}',
                  accent: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricInfo extends StatelessWidget {
  const _MetricInfo({
    required this.label,
    required this.value,
    this.accent = false,
  });

  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: accent ? colors.primary : colors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onActionTap, child: Text(actionLabel!)),
      ],
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

class _EmptyAssignedEmployeesCard extends StatelessWidget {
  const _EmptyAssignedEmployeesCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.groups_rounded, size: 40, color: colors.primary),
          const SizedBox(height: 12),
          Text(
            'Aun no hay personal asignado.',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega empleados a esta obra para comenzar a relacionar operacion y horas.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectActivityTimeline extends StatelessWidget {
  const _ProjectActivityTimeline({required this.activities});

  final List<ProjectActivityItem> activities;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: activities
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == activities.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 26,
                  child: Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: item.isHighlighted
                              ? const Color(0xFF1D52C2)
                              : const Color(0xFFB7C2D6),
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 64,
                          color: const Color(0xFFD8E0EC),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.caption,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.detail,
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
                ),
              ],
            );
          })
          .toList(growable: false),
    );
  }
}

({Color background, Color foreground}) _statusStyle(ProjectStatusCode status) {
  switch (status) {
    case ProjectStatusCode.completed:
      return (
        background: const Color(0xFFF3F5F8),
        foreground: const Color(0xFF687588),
      );
    case ProjectStatusCode.inProgress:
      return (
        background: const Color(0xFFFFF1C9),
        foreground: const Color(0xFFAD6200),
      );
    case ProjectStatusCode.active:
      return (
        background: const Color(0xFFE6F7EC),
        foreground: const Color(0xFF149954),
      );
  }
}
