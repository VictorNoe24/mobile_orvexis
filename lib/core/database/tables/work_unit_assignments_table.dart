import 'package:drift/drift.dart';
import 'organizations_table.dart';
import 'work_units_table.dart';
import 'org_users_table.dart';
import 'teams_table.dart';

class WorkUnitAssignments extends Table {
  TextColumn get idAssignment => text()();
  TextColumn get organizationId =>
      text().references(Organizations, #idOrganization)();
  TextColumn get workUnitId => text().references(WorkUnits, #idWorkUnit)();
  TextColumn get orgUserId => text().references(OrgUsers, #idOrgUser)();
  TextColumn get teamId => text().nullable().references(Teams, #idTeam)();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {idAssignment};
}