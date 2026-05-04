import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_item.dart';
import 'package:mobile_orvexis/feature/projects/domain/usecases/get_projects_usecase.dart';

enum ProjectFilter { all, active, completed }

class ProjectsController extends ChangeNotifier {
  ProjectsController(this._getCurrentSessionUseCase, this._getProjectsUseCase) {
    searchController.addListener(_handleSearchChanged);
  }

  final GetCurrentSessionUseCase _getCurrentSessionUseCase;
  final GetProjectsUseCase _getProjectsUseCase;
  final TextEditingController searchController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  ProjectFilter selectedFilter = ProjectFilter.all;
  List<ProjectItem> _projects = const [];
  bool _isDisposed = false;

  List<ProjectItem> get visibleProjects {
    return _projects
        .where((project) {
          return switch (selectedFilter) {
            ProjectFilter.all => true,
            ProjectFilter.active =>
              project.status == ProjectStatusCode.active ||
                  project.status == ProjectStatusCode.inProgress,
            ProjectFilter.completed =>
              project.status == ProjectStatusCode.completed,
          };
        })
        .toList(growable: false);
  }

  Future<void> initialize() async {
    await refresh();
  }

  Future<void> refresh() async {
    if (_isDisposed) {
      return;
    }

    isLoading = true;
    errorMessage = null;
    _notifySafely();

    try {
      final session = await _getCurrentSessionUseCase();
      if (_isDisposed) {
        return;
      }

      if (session == null) {
        throw Exception('No se encontro una sesion activa.');
      }

      _projects = await _getProjectsUseCase(
        organizationId: session.organizationId,
        query: searchController.text,
      );
      if (_isDisposed) {
        return;
      }
    } catch (error) {
      if (_isDisposed) {
        return;
      }
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      if (!_isDisposed) {
        isLoading = false;
        _notifySafely();
      }
    }
  }

  void selectFilter(ProjectFilter filter) {
    if (_isDisposed || selectedFilter == filter) return;
    selectedFilter = filter;
    _notifySafely();
  }

  void _handleSearchChanged() {
    if (_isDisposed) {
      return;
    }
    refresh();
  }

  void _notifySafely() {
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    super.dispose();
  }
}
