import 'package:drift/drift.dart';
import 'package:mobile_orvexis/core/database/app_database.dart';
import 'package:mobile_orvexis/core/database/global_status_defaults.dart';
import 'package:mobile_orvexis/core/helpers/uuid_helper.dart';
import 'package:mobile_orvexis/feature/roles/domain/entities/create_role_input.dart';
import 'package:mobile_orvexis/feature/roles/domain/entities/role_form_data.dart';
import 'package:mobile_orvexis/feature/roles/domain/entities/role_item.dart';

class RolesLocalDataSource {
  const RolesLocalDataSource(this._database);

  final AppDatabase _database;

  Future<List<RoleItem>> getRoles({required String organizationId}) async {
    final rows =
        await (_database.select(_database.roles)
              ..where((tbl) => tbl.organizationId.equals(organizationId))
              ..orderBy([
                (tbl) => OrderingTerm.asc(tbl.isSystem),
                (tbl) => OrderingTerm.asc(tbl.name),
              ]))
            .get();

    return rows
        .map(
          (row) => RoleItem(
            id: row.idRole,
            name: row.name,
            code: row.code,
            isSystem: row.isSystem,
            isActive: row.globalStatusId == GlobalStatusDefaults.activeId,
          ),
        )
        .toList();
  }

  Future<RoleFormData> getRoleById({
    required String organizationId,
    required String roleId,
  }) async {
    final role =
        await (_database.select(_database.roles)..where(
              (tbl) =>
                  tbl.organizationId.equals(organizationId) &
                  tbl.idRole.equals(roleId),
            ))
            .getSingleOrNull();

    if (role == null) {
      throw Exception('No se encontro el rol solicitado.');
    }

    return RoleFormData(
      id: role.idRole,
      name: role.name,
      code: role.code,
      isSystem: role.isSystem,
    );
  }

  Future<String> createRole({
    required String organizationId,
    required CreateRoleInput input,
  }) async {
    final normalizedName = _validateRoleName(input.name);
    final normalizedCode = _normalizeRoleCode(normalizedName);
    await _ensureRoleNameIsUnique(
      organizationId: organizationId,
      normalizedName: normalizedName,
      normalizedCode: normalizedCode,
    );

    final roleId = UuidHelper.generate();
    await _database
        .into(_database.roles)
        .insert(
          RolesCompanion(
            idRole: Value(roleId),
            organizationId: Value(organizationId),
            code: Value(normalizedCode),
            name: Value(normalizedName),
            isSystem: const Value(false),
          ),
        );

    return normalizedName;
  }

  Future<String> updateRole({
    required String organizationId,
    required String roleId,
    required CreateRoleInput input,
  }) async {
    final currentRole =
        await (_database.select(_database.roles)..where(
              (tbl) =>
                  tbl.organizationId.equals(organizationId) &
                  tbl.idRole.equals(roleId),
            ))
            .getSingleOrNull();

    if (currentRole == null) {
      throw Exception('No se encontro el rol solicitado.');
    }

    if (currentRole.isSystem) {
      throw Exception('Los roles del sistema no se pueden editar.');
    }

    final normalizedName = _validateRoleName(input.name);
    final normalizedCode = _normalizeRoleCode(normalizedName);
    await _ensureRoleNameIsUnique(
      organizationId: organizationId,
      normalizedName: normalizedName,
      normalizedCode: normalizedCode,
      excludingRoleId: roleId,
    );

    await (_database.update(
      _database.roles,
    )..where((tbl) => tbl.idRole.equals(roleId))).write(
      RolesCompanion(name: Value(normalizedName), code: Value(normalizedCode)),
    );

    return normalizedName;
  }

  String _validateRoleName(String value) {
    final normalizedName = value.trim();
    if (normalizedName.isEmpty) {
      throw Exception('Ingresa el nombre del rol.');
    }
    return normalizedName;
  }

  Future<void> _ensureRoleNameIsUnique({
    required String organizationId,
    required String normalizedName,
    required String normalizedCode,
    String? excludingRoleId,
  }) async {
    final roles =
        await (_database.select(_database.roles)..where(
              (tbl) =>
                  tbl.organizationId.equals(organizationId) &
                  tbl.globalStatusId.equals(GlobalStatusDefaults.activeId),
            ))
            .get();

    final normalizedNameLower = normalizedName.toLowerCase();
    for (final role in roles) {
      if (excludingRoleId != null && role.idRole == excludingRoleId) continue;
      if (role.code == normalizedCode ||
          role.name.trim().toLowerCase() == normalizedNameLower) {
        throw Exception('Ya existe un rol con ese nombre en la organizacion.');
      }
    }
  }

  String _normalizeRoleCode(String roleName) {
    return roleName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
}
