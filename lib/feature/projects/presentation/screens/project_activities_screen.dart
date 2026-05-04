import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_activity_item.dart';
import 'package:mobile_orvexis/feature/projects/presentation/providers/project_detail_controller.dart';

class ProjectActivitiesScreen extends StatefulWidget {
  const ProjectActivitiesScreen({
    super.key,
    required this.projectId,
    required this.controller,
  });

  final String projectId;
  final ProjectDetailController controller;

  @override
  State<ProjectActivitiesScreen> createState() =>
      _ProjectActivitiesScreenState();
}

class _ProjectActivitiesScreenState extends State<ProjectActivitiesScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.load(widget.projectId);
  }

  @override
  void didUpdateWidget(covariant ProjectActivitiesScreen oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final detail = widget.controller.detail;

        return Scaffold(
          appBar: AppBar(title: const Text('Actividad del proyecto')),
          body: widget.controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : widget.controller.errorMessage != null || detail == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      widget.controller.errorMessage ??
                          'No se pudo cargar la actividad de la obra.',
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
                              '${detail.activities.length} movimientos visibles en la obra',
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
                        child: detail.activities.isEmpty
                            ? const _EmptyActivitiesState()
                            : SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  12,
                                  16,
                                  24,
                                ),
                                child: _ProjectActivityTimeline(
                                  activities: detail.activities,
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

class _EmptyActivitiesState extends StatelessWidget {
  const _EmptyActivitiesState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timeline_rounded, size: 42, color: colors.primary),
            const SizedBox(height: 12),
            Text(
              'Aún no hay actividad para mostrar en esta obra.',
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
