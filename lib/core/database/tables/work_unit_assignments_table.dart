import 'package:drift/drift.dart';
import '../global_status_defaults.dart';
import '../../helpers/date_helper.dart';
import '../../helpers/uuid_helper.dart';
import 'global_statuses_table.dart';
import 'organizations_table.dart';
import 'work_units_table.dart';
import 'org_users_table.dart';
import 'teams_table.dart';

class WorkUnitAssignments extends Table {
  TextColumn get idAssignment =>
      text().clientDefault(() => UuidHelper.generate())();
  TextColumn get organizationId =>
      text().references(Organizations, #idOrganization)();
  TextColumn get workUnitId => text().references(WorkUnits, #idWorkUnit)();
  TextColumn get orgUserId => text().references(OrgUsers, #idOrgUser)();
  TextColumn get teamId => text().nullable().references(Teams, #idTeam)();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get globalStatusId => text()
      .clientDefault(() => GlobalStatusDefaults.activeId)
      .references(GlobalStatuses, #idGlobalStatus)();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateHelper.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateHelper.now())();

  @override
  Set<Column> get primaryKey => {idAssignment};
}
