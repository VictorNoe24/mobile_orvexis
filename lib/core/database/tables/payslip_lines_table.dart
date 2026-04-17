import 'package:drift/drift.dart';
import '../../helpers/date_helper.dart';
import '../../helpers/uuid_helper.dart';
import 'payslips_table.dart';
import 'pay_components_table.dart';
import 'work_units_table.dart';

class PayslipLines extends Table {
  TextColumn get idLine => text().clientDefault(() => UuidHelper.generate())();
  TextColumn get payslipId => text().references(Payslips, #idPayslip)();
  TextColumn get componentId =>
      text().references(PayComponents, #idComponent)();
  TextColumn get workUnitId =>
      text().nullable().references(WorkUnits, #idWorkUnit)();
  RealColumn get quantity => real().nullable()();
  RealColumn get rate => real().nullable()();
  RealColumn get amount => real().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateHelper.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateHelper.now())();

  @override
  Set<Column> get primaryKey => {idLine};
}
