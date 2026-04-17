import 'package:drift/drift.dart';
import '../../helpers/date_helper.dart';
import '../../helpers/uuid_helper.dart';
import 'organizations_table.dart';
import 'org_users_table.dart';
import 'work_units_table.dart';

class OvertimeEntries extends Table {
  TextColumn get idOvertime =>
      text().clientDefault(() => UuidHelper.generate())();
  TextColumn get organizationId =>
      text().references(Organizations, #idOrganization)();
  TextColumn get orgUserId => text().references(OrgUsers, #idOrgUser)();
  TextColumn get workUnitId => text().references(WorkUnits, #idWorkUnit)();
  DateTimeColumn get workDate => dateTime()();
  IntColumn get minutes => integer()();
  RealColumn get multiplier => real().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateHelper.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateHelper.now())();

  @override
  Set<Column> get primaryKey => {idOvertime};
}
