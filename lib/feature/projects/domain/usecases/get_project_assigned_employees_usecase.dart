import 'package:mobile_orvexis/feature/projects/domain/entities/project_assigned_employee.dart';
import 'package:mobile_orvexis/feature/projects/domain/repositories/projects_repository.dart';

class GetProjectAssignedEmployeesUseCase {
  const GetProjectAssignedEmployeesUseCase(this._repository);

  final ProjectsRepository _repository;

  Future<List<ProjectAssignedEmployee>> call({
    required String organizationId,
    required String projectId,
  }) {
    return _repository.getAssignedEmployees(
      organizationId: organizationId,
      projectId: projectId,
    );
  }
}
