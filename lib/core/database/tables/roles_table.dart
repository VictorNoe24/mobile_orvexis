import 'package:drift/drift.dart';
import 'organizations_table.dart';

class Roles extends Table {
  TextColumn get idRole => text()();
  TextColumn get organizationId =>
      text().references(Organizations, #idOrganization)();
  TextColumn get code => text()();
  TextColumn get name => text()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {idRole};
}