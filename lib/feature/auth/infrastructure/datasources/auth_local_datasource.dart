import 'package:drift/drift.dart';
import 'package:mobile_orvexis/core/database/app_database.dart';
import 'package:mobile_orvexis/core/database/daos/org_users_dao.dart';
import 'package:mobile_orvexis/core/helpers/uuid_helper.dart';
import 'package:mobile_orvexis/feature/auth/domain/entities/register_admin_organization_input.dart';

class AuthLocalDataSource {
  const AuthLocalDataSource(this._database);

  final AppDatabase _database;

  Future<void> registerAdminWithOrganization(
    RegisterAdminOrganizationInput input,
  ) async {
    final normalizedEmail = input.adminUser.email.trim().toLowerCase();

    final userId = UuidHelper.generate();
    final organizationId = UuidHelper.generate();
    final relationId = UuidHelper.generate();
    final roleId = UuidHelper.generate();
    final roleAssignmentId = UuidHelper.generate();

    await _database.transaction(() async {
      await _database.usersDao.insertUser(
        UsersCompanion(
          idUser: Value(userId),
          name: Value(input.adminUser.name),
          firstSurname: Value(input.adminUser.firstSurname),
          secondLastName: Value(input.adminUser.secondSurname),
          email: Value(normalizedEmail),
          phone: Value(input.adminUser.phone),
        ),
      );

      await _database.organizationsDao.insertOrganization(
        OrganizationsCompanion(
          idOrganization: Value(organizationId),
          name: Value(input.organization.name),
          taxId: Value(input.organization.taxId),
          timezone: Value(input.organization.timezone),
          logoUrl: Value(input.organization.logoUrl),
          brandColor: Value(input.organization.brandColorHex),
        ),
      );

      await _database.orgUsersDao.insertRelation(
        OrgUsersCompanion(
          idOrgUser: Value(relationId),
          organizationId: Value(organizationId),
          userId: Value(userId),
          joinedAt: Value(DateTime.now()),
        ),
      );

      await _database
          .into(_database.roles)
          .insert(
            RolesCompanion(
              idRole: Value(roleId),
              organizationId: Value(organizationId),
              code: const Value('admin'),
              name: const Value('Administrador'),
              isSystem: const Value(true),
            ),
          );

      await _database
          .into(_database.orgUserRoles)
          .insert(
            OrgUserRolesCompanion(
              idOrgUserRole: Value(roleAssignmentId),
              orgUserId: Value(relationId),
              roleId: Value(roleId),
              assignedAt: Value(DateTime.now()),
            ),
          );
    });
  }

  Future<User?> getUserByEmail(String email) {
    return _database.usersDao.getUserByEmail(email.trim().toLowerCase());
  }

  Future<List<OrgUserWithDetails>> getOrganizationsByUser(String userId) {
    return _database.orgUsersDao.getOrganizationsByUser(userId);
  }
}
