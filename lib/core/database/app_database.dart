import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database_triggers.dart';
import 'global_status_defaults.dart';
import '../helpers/date_helper.dart';
import '../helpers/uuid_helper.dart';
import 'tables/organizations_table.dart';
import 'tables/users_table.dart';
import 'tables/org_users_table.dart';
import 'tables/roles_table.dart';
import 'tables/org_user_roles_table.dart';
import 'tables/statuses_table.dart';
import 'tables/global_statuses_table.dart';
import 'tables/work_units_table.dart';
import 'tables/teams_table.dart';
import 'tables/work_unit_assignments_table.dart';
import 'tables/payroll_policies_table.dart';
import 'tables/employee_contracts_table.dart';
import 'tables/attendance_events_table.dart';
import 'tables/overtime_entries_table.dart';
import 'tables/piecework_catalog_table.dart';
import 'tables/piecework_entries_table.dart';
import 'tables/payroll_periods_table.dart';
import 'tables/payroll_runs_table.dart';
import 'tables/payslips_table.dart';
import 'tables/pay_components_table.dart';
import 'tables/payslip_lines_table.dart';
import 'tables/employee_loans_table.dart';
import 'tables/loan_installments_table.dart';

import 'daos/organizations_dao.dart';
import 'daos/users_dao.dart';
import 'daos/org_users_dao.dart';
import 'seeders/global_statuses_seeder.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Organizations,
    Users,
    OrgUsers,
    Roles,
    OrgUserRoles,
    Statuses,
    GlobalStatuses,
    WorkUnits,
    Teams,
    WorkUnitAssignments,
    PayrollPolicies,
    EmployeeContracts,
    AttendanceEvents,
    OvertimeEntries,
    PieceworkCatalog,
    PieceworkEntries,
    PayrollPeriods,
    PayrollRuns,
    Payslips,
    PayComponents,
    PayslipLines,
    EmployeeLoans,
    LoanInstallments,
  ],
  daos: [
    OrganizationsDao,
    UsersDao,
    OrgUsersDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await createUpdatedAtTriggers(this);
          await GlobalStatusesSeeder(this).seed();
        },
        beforeOpen: (details) async {
          await createUpdatedAtTriggers(this);
          await GlobalStatusesSeeder(this).seed();
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'payroll_system.sqlite'));
    return NativeDatabase(file);
  });
}
