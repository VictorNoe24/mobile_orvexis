import 'package:drift/drift.dart';
import '../../helpers/date_helper.dart';
import '../../helpers/uuid_helper.dart';
import 'organizations_table.dart';
import 'org_users_table.dart';
import 'work_units_table.dart';
import 'statuses_table.dart';

class AttendanceEvents extends Table {
  TextColumn get idAttendance =>
      text().clientDefault(() => UuidHelper.generate())();
  TextColumn get organizationId =>
      text().references(Organizations, #idOrganization)();
  TextColumn get orgUserId => text().references(OrgUsers, #idOrgUser)();
  TextColumn get workUnitId => text().references(WorkUnits, #idWorkUnit)();
  DateTimeColumn get workDate => dateTime()();
  IntColumn get minutesWorked => integer().nullable()();
  TextColumn get statusId => text().references(Statuses, #idStatus)();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateHelper.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateHelper.now())();

  @override
  Set<Column> get primaryKey => {idAttendance};
}
