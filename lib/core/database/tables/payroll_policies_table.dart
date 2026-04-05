import 'package:drift/drift.dart';
import 'organizations_table.dart';

class PayrollPolicies extends Table {
  TextColumn get idPolicy => text()();
  TextColumn get organizationId =>
      text().references(Organizations, #idOrganization)();
  TextColumn get name => text()();
  TextColumn get payFrequency => text()();
  TextColumn get currency => text().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {idPolicy};
}