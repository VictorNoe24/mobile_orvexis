import 'package:mobile_orvexis/feature/projects/domain/entities/project_form_data.dart';
import 'package:mobile_orvexis/feature/projects/domain/repositories/projects_repository.dart';

class GetProjectFormDataUseCase {
  const GetProjectFormDataUseCase(this._repository);

  final ProjectsRepository _repository;

  Future<ProjectFormData> call({
    required String organizationId,
    required String projectId,
  }) {
    return _repository.getProjectFormData(
      organizationId: organizationId,
      projectId: projectId,
    );
  }
}
