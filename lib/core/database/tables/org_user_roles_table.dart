import 'package:drift/drift.dart';
import 'org_users_table.dart';
import 'roles_table.dart';

class OrgUserRoles extends Table {
  TextColumn get idOrgUserRole => text()();
  TextColumn get orgUserId => text().references(OrgUsers, #idOrgUser)();
  TextColumn get roleId => text().references(Roles, #idRole)();
  DateTimeColumn get assignedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {idOrgUserRole};
}