import 'package:mobile_orvexis/feature/roles/domain/entities/create_role_input.dart';
import 'package:mobile_orvexis/feature/roles/domain/entities/role_form_data.dart';
import 'package:mobile_orvexis/feature/roles/domain/entities/role_item.dart';
import 'package:mobile_orvexis/feature/roles/domain/repositories/roles_repository.dart';
import 'package:mobile_orvexis/feature/roles/infrastructure/datasources/roles_local_datasource.dart';

class RolesRepositoryImpl implements RolesRepository {
  const RolesRepositoryImpl(this._dataSource);

  final RolesLocalDataSource _dataSource;

  @override
  Future<List<RoleItem>> getRoles({
    required String organizationId,
  }) {
    return _dataSource.getRoles(organizationId: organizationId);
  }

  @override
  Future<RoleFormData> getRoleById({
    required String organizationId,
    required String roleId,
  }) {
    return _dataSource.getRoleById(
      organizationId: organizationId,
      roleId: roleId,
    );
  }

  @override
  Future<String> createRole({
    required String organizationId,
    required CreateRoleInput input,
  }) {
    return _dataSource.createRole(
      organizationId: organizationId,
      input: input,
    );
  }

  @override
  Future<String> updateRole({
    required String organizationId,
    required String roleId,
    required CreateRoleInput input,
  }) {
    return _dataSource.updateRole(
      organizationId: organizationId,
      roleId: roleId,
      input: input,
    );
  }
}
