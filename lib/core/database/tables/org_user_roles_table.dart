import 'package:drift/drift.dart';
import '../../helpers/date_helper.dart';
import '../../helpers/uuid_helper.dart';
import 'org_users_table.dart';
import 'roles_table.dart';

class OrgUserRoles extends Table {
  TextColumn get idOrgUserRole =>
      text().clientDefault(() => UuidHelper.generate())();
  TextColumn get orgUserId => text().references(OrgUsers, #idOrgUser)();
  TextColumn get roleId => text().references(Roles, #idRole)();
  DateTimeColumn get assignedAt => dateTime().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateHelper.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateHelper.now())();

  @override
  Set<Column> get primaryKey => {idOrgUserRole};
}
