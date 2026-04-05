import 'package:drift/drift.dart';
import 'organizations_table.dart';

class PayComponents extends Table {
  TextColumn get idComponent => text()();
  TextColumn get organizationId =>
      text().references(Organizations, #idOrganization)();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {idComponent};
}