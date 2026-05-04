import 'package:mobile_orvexis/feature/roles/domain/entities/create_role_input.dart';
import 'package:mobile_orvexis/feature/roles/domain/entities/role_form_data.dart';
import 'package:mobile_orvexis/feature/roles/domain/entities/role_item.dart';

abstract class RolesRepository {
  Future<List<RoleItem>> getRoles({required String organizationId});

  Future<RoleFormData> getRoleById({
    required String organizationId,
    required String roleId,
  });

  Future<String> createRole({
    required String organizationId,
    required CreateRoleInput input,
  });

  Future<String> updateRole({
    required String organizationId,
    required String roleId,
    required CreateRoleInput input,
  });
}
