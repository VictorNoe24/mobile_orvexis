import 'package:mobile_orvexis/feature/projects/domain/entities/create_project_input.dart';
import 'package:mobile_orvexis/feature/projects/domain/repositories/projects_repository.dart';

class UpdateProjectUseCase {
  const UpdateProjectUseCase(this._repository);

  final ProjectsRepository _repository;

  Future<void> call({
    required String organizationId,
    required String projectId,
    required CreateProjectInput input,
  }) {
    return _repository.updateProject(
      organizationId: organizationId,
      projectId: projectId,
      input: input,
    );
  }
}
