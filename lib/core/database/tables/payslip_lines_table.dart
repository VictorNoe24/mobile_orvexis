import 'package:drift/drift.dart';
import 'payslips_table.dart';
import 'pay_components_table.dart';
import 'work_units_table.dart';

class PayslipLines extends Table {
  TextColumn get idLine => text()();
  TextColumn get payslipId => text().references(Payslips, #idPayslip)();
  TextColumn get componentId =>
      text().references(PayComponents, #idComponent)();
  TextColumn get workUnitId =>
      text().nullable().references(WorkUnits, #idWorkUnit)();
  RealColumn get quantity => real().nullable()();
  RealColumn get rate => real().nullable()();
  RealColumn get amount => real().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {idLine};
}