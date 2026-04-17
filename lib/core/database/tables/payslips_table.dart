import 'package:drift/drift.dart';
import '../../helpers/date_helper.dart';
import '../../helpers/uuid_helper.dart';
import 'organizations_table.dart';
import 'payroll_runs_table.dart';
import 'employee_contracts_table.dart';
import 'org_users_table.dart';
import 'statuses_table.dart';

class Payslips extends Table {
  TextColumn get idPayslip =>
      text().clientDefault(() => UuidHelper.generate())();
  TextColumn get organizationId =>
      text().references(Organizations, #idOrganization)();
  TextColumn get runId => text().references(PayrollRuns, #idRun)();
  TextColumn get contractId =>
      text().references(EmployeeContracts, #idContract)();
  TextColumn get orgUserId => text().references(OrgUsers, #idOrgUser)();
  RealColumn get grossAmount => real().nullable()();
  RealColumn get deductionsAmount => real().nullable()();
  RealColumn get netAmount => real().nullable()();
  TextColumn get statusId => text().references(Statuses, #idStatus)();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateHelper.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateHelper.now())();

  @override
  Set<Column> get primaryKey => {idPayslip};
}
