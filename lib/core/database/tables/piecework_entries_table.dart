import 'package:drift/drift.dart';
import 'organizations_table.dart';
import 'org_users_table.dart';
import 'work_units_table.dart';
import 'piecework_catalog_table.dart';

class PieceworkEntries extends Table {
  TextColumn get idEntry => text()();
  TextColumn get organizationId =>
      text().references(Organizations, #idOrganization)();
  TextColumn get orgUserId => text().references(OrgUsers, #idOrgUser)();
  TextColumn get workUnitId => text().references(WorkUnits, #idWorkUnit)();
  TextColumn get pieceworkId =>
      text().references(PieceworkCatalog, #idPiecework)();
  DateTimeColumn get workDate => dateTime()();
  RealColumn get quantity => real()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {idEntry};
}