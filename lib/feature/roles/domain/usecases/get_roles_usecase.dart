import 'package:mobile_orvexis/feature/roles/domain/entities/role_item.dart';
import 'package:mobile_orvexis/feature/roles/domain/repositories/roles_repository.dart';

class GetRolesUseCase {
  const GetRolesUseCase(this._repository);

  final RolesRepository _repository;

  Future<List<RoleItem>> call({
    required String organizationId,
  }) {
    return _repository.getRoles(organizationId: organizationId);
  }
}
