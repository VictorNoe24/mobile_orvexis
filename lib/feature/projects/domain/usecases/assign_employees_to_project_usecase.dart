import 'package:mobile_orvexis/feature/projects/domain/repositories/projects_repository.dart';

class AssignEmployeesToProjectUseCase {
  const AssignEmployeesToProjectUseCase(this._repository);

  final ProjectsRepository _repository;

  Future<void> call({
    required String organizationId,
    required String projectId,
    required List<String> orgUserIds,
  }) {
    return _repository.assignEmployeesToProject(
      organizationId: organizationId,
      projectId: projectId,
      orgUserIds: orgUserIds,
    );
  }
}
