import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_item.dart';
import 'package:mobile_orvexis/feature/projects/presentation/providers/projects_controller.dart';

class ProjectsTab extends StatelessWidget {
  const ProjectsTab({super.key, required this.controller});

  final ProjectsController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage != null) {
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

        final projects = controller.visibleProjects;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          children: [
            _ProjectsSearchField(controller: controller),
            const SizedBox(height: 18),
            _ProjectFilterTabs(
              selectedFilter: controller.selectedFilter,
              onSelected: controller.selectFilter,
            ),
            const SizedBox(height: 18),
            if (projects.isEmpty)
              const _ProjectsEmptyState()
            else
              ...projects.map(
                (project) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ProjectCard(
                    project: project,
                    onProjectUpdated: controller.refresh,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProjectsSearchField extends StatelessWidget {
  const _ProjectsSearchField({required this.controller});

  final ProjectsController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.searchController,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: 'Buscar proyectos por nombre o ubicacion',
        prefixIcon: Icon(Icons.search_rounded),
      ),
    );
  }
}

class _ProjectFilterTabs extends StatelessWidget {
  const _ProjectFilterTabs({
    required this.selectedFilter,
    required this.onSelected,
  });

  final ProjectFilter selectedFilter;
  final ValueChanged<ProjectFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _ProjectFilterButton(
              label: 'Todos',
              selected: selectedFilter == ProjectFilter.all,
              onTap: () => onSelected(ProjectFilter.all),
            ),
          ),
          Expanded(
            child: _ProjectFilterButton(
              label: 'Activos',
              selected: selectedFilter == ProjectFilter.active,
              onTap: () => onSelected(ProjectFilter.active),
            ),
          ),
          Expanded(
            child: _ProjectFilterButton(
              label: 'Completados',
              selected: selectedFilter == ProjectFilter.completed,
              onTap: () => onSelected(ProjectFilter.completed),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectFilterButton extends StatelessWidget {
  const _ProjectFilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? colors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? colors.onPrimary : colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectsEmptyState extends StatelessWidget {
  const _ProjectsEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.apartment_rounded, size: 42, color: colors.primary),
          const SizedBox(height: 14),
          Text(
            'Todavia no hay proyectos guardados.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Usa el boton + para crear tu primer proyecto y almacenarlo en la base local.',
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

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project, required this.onProjectUpdated});

  final ProjectItem project;
  final Future<void> Function() onProjectUpdated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          final didUpdate = await context.push<bool>('/projects/${project.id}');
          if (didUpdate == true) {
            await onProjectUpdated();
          }
        },
        child: Ink(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProjectHero(project: project),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (project.code != null && project.code!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          project.code!,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      project.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ProjectMetaRow(
                      icon: Icons.location_on_rounded,
                      text: project.location,
                    ),
                    const SizedBox(height: 8),
                    _ProjectMetaRow(
                      icon: Icons.calendar_today_rounded,
                      text: project.dateLabel,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _ProjectStatusInlineBadge(project: project),
                        const Spacer(),
                        FilledButton.tonal(
                          onPressed: () async {
                            final didUpdate = await context.push<bool>(
                              '/projects/${project.id}',
                            );
                            if (didUpdate == true) {
                              await onProjectUpdated();
                            }
                          },
                          child: const Text('Ver detalle'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectHero extends StatelessWidget {
  const _ProjectHero({required this.project});

  final ProjectItem project;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (project.imagePath != null && project.imagePath!.isNotEmpty)
            Image.file(
              File(project.imagePath!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _ProjectHeroFallback(colors: colors);
              },
            )
          else
            _ProjectHeroFallback(colors: colors),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.05),
                  Colors.black.withValues(alpha: 0.35),
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: _ProjectStatusBadge(project: project),
          ),
        ],
      ),
    );
  }
}

class _ProjectHeroFallback extends StatelessWidget {
  const _ProjectHeroFallback({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary,
            colors.secondary.withValues(alpha: 0.80),
            colors.surfaceContainerHighest,
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.apartment_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }
}

class _ProjectMetaRow extends StatelessWidget {
  const _ProjectMetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colors.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectStatusInlineBadge extends StatelessWidget {
  const _ProjectStatusInlineBadge({required this.project});

  final ProjectItem project;

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(project.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        project.statusLabel,
        style: TextStyle(color: style.foreground, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ProjectStatusBadge extends StatelessWidget {
  const _ProjectStatusBadge({required this.project});

  final ProjectItem project;

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(project.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        project.statusLabel.toUpperCase(),
        style: TextStyle(
          color: style.foreground,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
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
        background: const Color(0xFFE8F1FF),
        foreground: const Color(0xFF1D52C2),
      );
  }
}
