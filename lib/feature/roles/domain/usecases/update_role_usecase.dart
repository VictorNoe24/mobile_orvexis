import 'package:mobile_orvexis/feature/roles/domain/entities/create_role_input.dart';
import 'package:mobile_orvexis/feature/roles/domain/repositories/roles_repository.dart';

class UpdateRoleUseCase {
  const UpdateRoleUseCase(this._repository);

  final RolesRepository _repository;

  Future<String> call({
    required String organizationId,
    required String roleId,
    required CreateRoleInput input,
  }) {
    return _repository.updateRole(
      organizationId: organizationId,
      roleId: roleId,
      input: input,
    );
  }
}
