import 'package:drift/drift.dart';
import '../../helpers/date_helper.dart';
import '../../helpers/uuid_helper.dart';
import 'employee_loans_table.dart';
import 'payroll_periods_table.dart';

class LoanInstallments extends Table {
  TextColumn get idInstallment =>
      text().clientDefault(() => UuidHelper.generate())();
  TextColumn get loanId => text().references(EmployeeLoans, #idLoan)();
  TextColumn get periodId => text().references(PayrollPeriods, #idPeriod)();
  RealColumn get amount => real().nullable()();
  BoolColumn get isPaid => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateHelper.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateHelper.now())();

  @override
  Set<Column> get primaryKey => {idInstallment};
}
