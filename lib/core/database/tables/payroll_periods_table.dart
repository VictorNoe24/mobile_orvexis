import 'package:drift/drift.dart';
import '../../helpers/date_helper.dart';
import '../../helpers/uuid_helper.dart';
import 'organizations_table.dart';
import 'payroll_policies_table.dart';
import 'statuses_table.dart';

class PayrollPeriods extends Table {
  TextColumn get idPeriod =>
      text().clientDefault(() => UuidHelper.generate())();
  TextColumn get organizationId =>
      text().references(Organizations, #idOrganization)();
  TextColumn get policyId => text().references(PayrollPolicies, #idPolicy)();
  DateTimeColumn get periodStart => dateTime()();
  DateTimeColumn get periodEnd => dateTime()();
  DateTimeColumn get payDate => dateTime().nullable()();
  TextColumn get statusId => text().references(Statuses, #idStatus)();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateHelper.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateHelper.now())();

  @override
  Set<Column> get primaryKey => {idPeriod};
}
