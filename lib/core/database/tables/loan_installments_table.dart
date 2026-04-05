import 'package:drift/drift.dart';
import 'employee_loans_table.dart';
import 'payroll_periods_table.dart';

class LoanInstallments extends Table {
  TextColumn get idInstallment => text()();
  TextColumn get loanId => text().references(EmployeeLoans, #idLoan)();
  TextColumn get periodId => text().references(PayrollPeriods, #idPeriod)();
  RealColumn get amount => real().nullable()();
  BoolColumn get isPaid => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {idInstallment};
}