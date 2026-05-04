import 'package:mobile_orvexis/feature/projects/domain/entities/project_detail.dart';
import 'package:mobile_orvexis/feature/projects/domain/repositories/projects_repository.dart';

class GetProjectDetailUseCase {
  const GetProjectDetailUseCase(this._repository);

  final ProjectsRepository _repository;

  Future<ProjectDetail> call({
    required String organizationId,
    required String projectId,
  }) {
    return _repository.getProjectDetail(
      organizationId: organizationId,
      projectId: projectId,
    );
  }
}
