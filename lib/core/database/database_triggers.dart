import 'package:drift/drift.dart';

class UpdatedAtTriggerDefinition {
  final String triggerName;
  final String tableName;
  final String idColumn;

  const UpdatedAtTriggerDefinition({
    required this.triggerName,
    required this.tableName,
    required this.idColumn,
  });
}

const List<UpdatedAtTriggerDefinition> updatedAtTriggers = [
  UpdatedAtTriggerDefinition(
    triggerName: 'organizations_set_updated_at',
    tableName: 'organizations',
    idColumn: 'id_organization',
  ),
  UpdatedAtTriggerDefinition(
    triggerName: 'users_set_updated_at',
    tableName: 'users',
    idColumn: 'id_user',
  ),
  UpdatedAtTriggerDefinition(
    triggerName: 'org_users_set_updated_at',
    tableName: 'org_users',
    idColumn: 'id_org_user',
  ),
  UpdatedAtTriggerDefinition(
    triggerName: 'roles_set_updated_at',
    tableName: 'roles',
    idColumn: 'id_role',
  ),
  UpdatedAtTriggerDefinition(
    triggerName: 'org_user_roles_set_updated_at',
    tableName: 'org_user_roles',
    idColumn: 'id_org_user_role',
  ),
  UpdatedAtTriggerDefinition(
    triggerName: 'statuses_set_updated_at',
    tableName: 'statuses',
    idColumn: 'id_status',
  ),
  UpdatedAtTriggerDefinition(
    triggerName: 'global_statuses_set_updated_at',
    tableName: 'global_statuses',
    idColumn: 'id_global_status',
  ),
  UpdatedAtTriggerDefinition(
    triggerName: 'work_units_set_updated_at',
    tableName: 'work_units',
    idColumn: 'id_work_unit',
  ),
  UpdatedAtTriggerDefinition(
    triggerName: 'teams_set_updated_at',
    tableName: 'teams',
    idColumn: 'id_team',
  ),
  UpdatedAtTriggerDefinition(
    triggerName: 'work_unit_assignments_set_updated_at',
    tableName: 'work_unit_assignments',
    idColumn: 'id_assignment',
  ),
  UpdatedAtTriggerDefinition(
    triggerName: 'payroll_policies_set_updated_at',
    tableName: 'payroll_policies',
    idColumn: 'id_policy',
  ),
  UpdatedAtTriggerDefinition(
    triggerName: 'employee_contracts_set_updated_at',
    tableName: 'employee_contracts',
    idColumn: 'id_contract',
  ),
  UpdatedAtTriggerDefinition(
    triggerName: 'attendance_events_set_updated_at',
    tableName: 'attendance_events',
    idColumn: 'id_attendance',
  ),
  UpdatedAtTriggerDefinition(
    triggerName: 'overtime_entries_set_updated_at',
    tableName: 'overtime_entries',
    idColumn: 'id_overtime',
  ),
  UpdatedAtTriggerDefinition(
    triggerName: 'piecework_catalog_set_updated_at',
    tableName: 'piecework_catalog',
    idColumn: 'id_piecework',
  ),
  UpdatedAtTriggerDefinition(
    triggerName: 'piecework_entries_set_updated_at',
    tableName: 'piecework_entries',
    idColumn: 'id_entry',
  ),
  UpdatedAtTriggerDefinition(
    triggerName: 'payroll_periods_set_updated_at',
    tableName: 'payroll_periods',
    idColumn: 'id_period',
  ),
  UpdatedAtTriggerDefinition(
    triggerName: 'payroll_runs_set_updated_at',
    tableName: 'payroll_runs',
    idColumn: 'id_run',
  ),
  UpdatedAtTriggerDefinition(
    triggerName: 'payslips_set_updated_at',
    tableName: 'payslips',
    idColumn: 'id_payslip',
  ),
  UpdatedAtTriggerDefinition(
    triggerName: 'pay_components_set_updated_at',
    tableName: 'pay_components',
    idColumn: 'id_component',
  ),
  UpdatedAtTriggerDefinition(
    triggerName: 'payslip_lines_set_updated_at',
    tableName: 'payslip_lines',
    idColumn: 'id_line',
  ),
  UpdatedAtTriggerDefinition(
    triggerName: 'employee_loans_set_updated_at',
    tableName: 'employee_loans',
    idColumn: 'id_loan',
  ),
  UpdatedAtTriggerDefinition(
    triggerName: 'loan_installments_set_updated_at',
    tableName: 'loan_installments',
    idColumn: 'id_installment',
  ),
];

Future<void> createUpdatedAtTriggers(GeneratedDatabase db) async {
  for (final trigger in updatedAtTriggers) {
    await db.customStatement('''
      CREATE TRIGGER IF NOT EXISTS ${trigger.triggerName}
      AFTER UPDATE ON ${trigger.tableName}
      FOR EACH ROW
      WHEN OLD.updated_at = NEW.updated_at
      BEGIN
        UPDATE ${trigger.tableName}
        SET updated_at = CURRENT_TIMESTAMP
        WHERE ${trigger.idColumn} = OLD.${trigger.idColumn};
      END;
    ''');
  }
}
