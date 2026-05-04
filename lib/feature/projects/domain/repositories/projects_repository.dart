import 'package:mobile_orvexis/feature/projects/domain/entities/create_project_input.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_assignable_employee.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_assigned_employee.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_detail.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_form_data.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_item.dart';

abstract class ProjectsRepository {
  Future<List<ProjectItem>> getProjects({
    required String organizationId,
    required String query,
  });

  Future<void> createProject({
    required String organizationId,
    required CreateProjectInput input,
  });

  Future<ProjectDetail> getProjectDetail({
    required String organizationId,
    required String projectId,
  });

  Future<List<ProjectAssignedEmployee>> getAssignedEmployees({
    required String organizationId,
    required String projectId,
  });

  Future<List<ProjectAssignableEmployee>> getAssignableEmployees({
    required String organizationId,
    required String projectId,
  });

  Future<void> assignEmployeesToProject({
    required String organizationId,
    required String projectId,
    required List<String> orgUserIds,
  });

  Future<void> removeEmployeeFromProject({
    required String organizationId,
    required String projectId,
    required String assignmentId,
  });

  Future<ProjectFormData> getProjectFormData({
    required String organizationId,
    required String projectId,
  });

  Future<void> updateProject({
    required String organizationId,
    required String projectId,
    required CreateProjectInput input,
  });
}
