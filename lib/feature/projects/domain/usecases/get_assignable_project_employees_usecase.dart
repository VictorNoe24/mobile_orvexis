import 'package:mobile_orvexis/feature/projects/domain/entities/project_assignable_employee.dart';
import 'package:mobile_orvexis/feature/projects/domain/repositories/projects_repository.dart';

class GetAssignableProjectEmployeesUseCase {
  const GetAssignableProjectEmployeesUseCase(this._repository);

  final ProjectsRepository _repository;

  Future<List<ProjectAssignableEmployee>> call({
    required String organizationId,
    required String projectId,
  }) {
    return _repository.getAssignableEmployees(
      organizationId: organizationId,
      projectId: projectId,
    );
  }
}
