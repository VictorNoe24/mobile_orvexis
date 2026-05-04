import 'package:mobile_orvexis/feature/projects/domain/repositories/projects_repository.dart';

class RemoveEmployeeFromProjectUseCase {
  const RemoveEmployeeFromProjectUseCase(this._repository);

  final ProjectsRepository _repository;

  Future<void> call({
    required String organizationId,
    required String projectId,
    required String assignmentId,
  }) {
    return _repository.removeEmployeeFromProject(
      organizationId: organizationId,
      projectId: projectId,
      assignmentId: assignmentId,
    );
  }
}
