import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/org_users_table.dart';
import '../tables/users_table.dart';
import '../tables/organizations_table.dart';

part 'org_users_dao.g.dart';

class OrgUserWithDetails {
  final OrgUser orgUser;
  final User user;
  final Organization organization;

  OrgUserWithDetails({
    required this.orgUser,
    required this.user,
    required this.organization,
  });
}

@DriftAccessor(tables: [OrgUsers, Users, Organizations])
class OrgUsersDao extends DatabaseAccessor<AppDatabase>
    with _$OrgUsersDaoMixin {
  OrgUsersDao(super.db);

  Future<List<OrgUser>> getAllRelations() {
    return select(orgUsers).get();
  }

  Stream<List<OrgUser>> watchAllRelations() {
    return select(orgUsers).watch();
  }

  Future<OrgUser?> getRelationById(String id) {
    return (select(orgUsers)..where((tbl) => tbl.idOrgUser.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertRelation(OrgUsersCompanion entity) {
    return into(orgUsers).insert(entity);
  }

  Future<int> deleteRelationById(String id) {
    return (delete(orgUsers)..where((tbl) => tbl.idOrgUser.equals(id))).go();
  }

  Future<List<OrgUserWithDetails>> getUsersByOrganization(String organizationId) async {
    final query = select(orgUsers).join([
      innerJoin(users, users.idUser.equalsExp(orgUsers.userId)),
      innerJoin(
        organizations,
        organizations.idOrganization.equalsExp(orgUsers.organizationId),
      ),
    ])
      ..where(orgUsers.organizationId.equals(organizationId));

    final rows = await query.get();

    return rows.map((row) {
      return OrgUserWithDetails(
        orgUser: row.readTable(orgUsers),
        user: row.readTable(users),
        organization: row.readTable(organizations),
      );
    }).toList();
  }

  Stream<List<OrgUserWithDetails>> watchUsersByOrganization(String organizationId) {
    final query = select(orgUsers).join([
      innerJoin(users, users.idUser.equalsExp(orgUsers.userId)),
      innerJoin(
        organizations,
        organizations.idOrganization.equalsExp(orgUsers.organizationId),
      ),
    ])
      ..where(orgUsers.organizationId.equals(organizationId));

    return query.watch().map((rows) {
      return rows.map((row) {
        return OrgUserWithDetails(
          orgUser: row.readTable(orgUsers),
          user: row.readTable(users),
          organization: row.readTable(organizations),
        );
      }).toList();
    });
  }

  Future<List<OrgUserWithDetails>> getOrganizationsByUser(String userId) async {
    final query = select(orgUsers).join([
      innerJoin(users, users.idUser.equalsExp(orgUsers.userId)),
      innerJoin(
        organizations,
        organizations.idOrganization.equalsExp(orgUsers.organizationId),
      ),
    ])
      ..where(orgUsers.userId.equals(userId));

    final rows = await query.get();

    return rows.map((row) {
      return OrgUserWithDetails(
        orgUser: row.readTable(orgUsers),
        user: row.readTable(users),
        organization: row.readTable(organizations),
      );
    }).toList();
  }

  Future<OrgUserWithDetails?> getRelationByOrganizationAndUser({
    required String organizationId,
    required String userId,
  }) async {
    final query = select(orgUsers).join([
      innerJoin(users, users.idUser.equalsExp(orgUsers.userId)),
      innerJoin(
        organizations,
        organizations.idOrganization.equalsExp(orgUsers.organizationId),
      ),
    ])
      ..where(
        orgUsers.organizationId.equals(organizationId) &
            orgUsers.userId.equals(userId),
      );

    final row = await query.getSingleOrNull();

    if (row == null) return null;

    return OrgUserWithDetails(
      orgUser: row.readTable(orgUsers),
      user: row.readTable(users),
      organization: row.readTable(organizations),
    );
  }
}