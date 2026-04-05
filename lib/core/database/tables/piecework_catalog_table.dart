import 'package:drift/drift.dart';
import 'organizations_table.dart';

class PieceworkCatalog extends Table {
  TextColumn get idPiecework => text()();
  TextColumn get organizationId =>
      text().references(Organizations, #idOrganization)();
  TextColumn get code => text().nullable()();
  TextColumn get description => text()();
  TextColumn get unit => text().nullable()();
  RealColumn get unitPrice => real().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {idPiecework};
}