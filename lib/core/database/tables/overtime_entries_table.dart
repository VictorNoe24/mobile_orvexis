import 'package:drift/drift.dart';
import 'organizations_table.dart';
import 'org_users_table.dart';
import 'work_units_table.dart';

class OvertimeEntries extends Table {
  TextColumn get idOvertime => text()();
  TextColumn get organizationId =>
      text().references(Organizations, #idOrganization)();
  TextColumn get orgUserId => text().references(OrgUsers, #idOrgUser)();
  TextColumn get workUnitId => text().references(WorkUnits, #idWorkUnit)();
  DateTimeColumn get workDate => dateTime()();
  IntColumn get minutes => integer()();
  RealColumn get multiplier => real().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {idOvertime};
}