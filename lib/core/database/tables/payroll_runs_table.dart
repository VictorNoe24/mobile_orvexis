import 'package:drift/drift.dart';
import 'organizations_table.dart';
import 'payroll_periods_table.dart';
import 'statuses_table.dart';

class PayrollRuns extends Table {
  TextColumn get idRun => text()();
  TextColumn get organizationId =>
      text().references(Organizations, #idOrganization)();
  TextColumn get periodId => text().references(PayrollPeriods, #idPeriod)();
  TextColumn get statusId => text().references(Statuses, #idStatus)();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get approvedAt => dateTime().nullable()();
  DateTimeColumn get paidAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {idRun};
}