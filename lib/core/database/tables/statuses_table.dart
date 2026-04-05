import 'package:drift/drift.dart';
import 'organizations_table.dart';

class Statuses extends Table {
  TextColumn get idStatus => text()();
  TextColumn get organizationId =>
      text().references(Organizations, #idOrganization)();
  TextColumn get entity => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().nullable()();
  BoolColumn get isTerminal => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {idStatus};
}