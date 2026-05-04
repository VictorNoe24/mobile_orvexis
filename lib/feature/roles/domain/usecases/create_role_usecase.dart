import 'package:mobile_orvexis/feature/roles/domain/entities/create_role_input.dart';
import 'package:mobile_orvexis/feature/roles/domain/repositories/roles_repository.dart';

class CreateRoleUseCase {
  const CreateRoleUseCase(this._repository);

  final RolesRepository _repository;

  Future<String> call({
    required String organizationId,
    required CreateRoleInput input,
  }) {
    return _repository.createRole(organizationId: organizationId, input: input);
  }
}
