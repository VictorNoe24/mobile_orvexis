import 'package:drift/drift.dart';
import 'organizations_table.dart';
import 'org_users_table.dart';
import 'payroll_policies_table.dart';

class EmployeeContracts extends Table {
  TextColumn get idContract => text()();
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
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {idContract};
}