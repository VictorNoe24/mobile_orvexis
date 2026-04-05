import 'package:drift/drift.dart';
import 'organizations_table.dart';
import 'work_units_table.dart';

class Teams extends Table {
  TextColumn get idTeam => text()();
  TextColumn get organizationId =>
      text().references(Organizations, #idOrganization)();
  TextColumn get workUnitId => text().references(WorkUnits, #idWorkUnit)();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {idTeam};
}