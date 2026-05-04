import 'package:mobile_orvexis/feature/projects/domain/entities/create_project_input.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_assignable_employee.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_assigned_employee.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_detail.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_form_data.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_item.dart';
import 'package:mobile_orvexis/feature/projects/domain/repositories/projects_repository.dart';
import 'package:mobile_orvexis/feature/projects/infrastructure/datasources/projects_local_datasource.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  const ProjectsRepositoryImpl(this._localDataSource);

  final ProjectsLocalDataSource _localDataSource;

  @override
  Future<void> createProject({
    required String organizationId,
    required CreateProjectInput input,
  }) {
    return _localDataSource.createProject(
      organizationId: organizationId,
      input: input,
    );
  }

  @override
  Future<List<ProjectItem>> getProjects({
    required String organizationId,
    required String query,
  }) {
    return _localDataSource.getProjects(
      organizationId: organizationId,
      query: query,
    );
  }

  @override
  Future<ProjectDetail> getProjectDetail({
    required String organizationId,
    required String projectId,
  }) {
    return _localDataSource.getProjectDetail(
      organizationId: organizationId,
      projectId: projectId,
    );
  }

  @override
  Future<List<ProjectAssignedEmployee>> getAssignedEmployees({
    required String organizationId,
    required String projectId,
  }) {
    return _localDataSource.getAssignedEmployees(
      organizationId: organizationId,
      projectId: projectId,
    );
  }

  @override
  Future<List<ProjectAssignableEmployee>> getAssignableEmployees({
    required String organizationId,
    required String projectId,
  }) {
    return _localDataSource.getAssignableEmployees(
      organizationId: organizationId,
      projectId: projectId,
    );
  }

  @override
  Future<void> assignEmployeesToProject({
    required String organizationId,
    required String projectId,
    required List<String> orgUserIds,
  }) {
    return _localDataSource.assignEmployeesToProject(
      organizationId: organizationId,
      projectId: projectId,
      orgUserIds: orgUserIds,
    );
  }

  @override
  Future<void> removeEmployeeFromProject({
    required String organizationId,
    required String projectId,
    required String assignmentId,
  }) {
    return _localDataSource.removeEmployeeFromProject(
      organizationId: organizationId,
      projectId: projectId,
      assignmentId: assignmentId,
    );
  }

  @override
  Future<ProjectFormData> getProjectFormData({
    required String organizationId,
    required String projectId,
  }) {
    return _localDataSource.getProjectFormData(
      organizationId: organizationId,
      projectId: projectId,
    );
  }

  @override
  Future<void> updateProject({
    required String organizationId,
    required String projectId,
    required CreateProjectInput input,
  }) {
    return _localDataSource.updateProject(
      organizationId: organizationId,
      projectId: projectId,
      input: input,
    );
  }
}
