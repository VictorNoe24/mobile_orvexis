import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/projects/domain/usecases/get_projects_usecase.dart';
import 'package:mobile_orvexis/feature/projects/presentation/providers/projects_controller.dart';
import 'package:mobile_orvexis/feature/projects/presentation/widgets/projects_screen/projects_tab.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({
    super.key,
    required this.getCurrentSessionUseCase,
    required this.getProjectsUseCase,
    required this.refreshToken,
  });

  final GetCurrentSessionUseCase getCurrentSessionUseCase;
  final GetProjectsUseCase getProjectsUseCase;
  final int refreshToken;

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  late final ProjectsController _controller = ProjectsController(
    widget.getCurrentSessionUseCase,
    widget.getProjectsUseCase,
  );

  @override
  void initState() {
    super.initState();
    _controller.initialize();
  }

  @override
  void didUpdateWidget(covariant ProjectsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _controller.refresh();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProjectsTab(controller: _controller);
  }
}
