import 'package:mobile_orvexis/feature/projects/domain/entities/create_project_input.dart';
import 'package:mobile_orvexis/feature/projects/domain/repositories/projects_repository.dart';

class CreateProjectUseCase {
  const CreateProjectUseCase(this._repository);

  final ProjectsRepository _repository;

  Future<void> call({
    required String organizationId,
    required CreateProjectInput input,
  }) {
    return _repository.createProject(
      organizationId: organizationId,
      input: input,
    );
  }
}
