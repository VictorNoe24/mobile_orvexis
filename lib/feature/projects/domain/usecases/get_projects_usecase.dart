import 'package:mobile_orvexis/feature/projects/domain/entities/project_item.dart';
import 'package:mobile_orvexis/feature/projects/domain/repositories/projects_repository.dart';

class GetProjectsUseCase {
  const GetProjectsUseCase(this._repository);

  final ProjectsRepository _repository;

  Future<List<ProjectItem>> call({
    required String organizationId,
    required String query,
  }) {
    return _repository.getProjects(
      organizationId: organizationId,
      query: query,
    );
  }
}
