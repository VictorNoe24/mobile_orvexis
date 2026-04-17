import 'package:drift/drift.dart';
import '../global_status_defaults.dart';
import '../../helpers/date_helper.dart';
import '../../helpers/uuid_helper.dart';
import 'global_statuses_table.dart';
import 'organizations_table.dart';
import 'org_users_table.dart';
import 'payroll_policies_table.dart';

class EmployeeContracts extends Table {
  TextColumn get idContract =>
      text().clientDefault(() => UuidHelper.generate())();
  TextColumn get organizationId =>
      text().references(Organizations, #idOrganization)();
  TextColumn get orgUserId => text().references(OrgUsers, #idOrgUser)();
  TextColumn get policyId => text().references(PayrollPolicies, #idPolicy)();
  TextColumn get contractType => text()();
  RealColumn get baseSalary => real().nullable()();
  RealColumn get hourlyRate => real().nullable()();
  RealColumn get dailyRate => real().nullable()();
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
  Set<Column> get primaryKey => {idContract};
}
