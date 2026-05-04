import 'package:mobile_orvexis/feature/roles/domain/entities/role_form_data.dart';
import 'package:mobile_orvexis/feature/roles/domain/repositories/roles_repository.dart';

class GetRoleByIdUseCase {
  const GetRoleByIdUseCase(this._repository);

  final RolesRepository _repository;

  Future<RoleFormData> call({
    required String organizationId,
    required String roleId,
  }) {
    return _repository.getRoleById(
      organizationId: organizationId,
      roleId: roleId,
    );
  }
}
