import 'package:drift/drift.dart';
import '../../helpers/date_helper.dart';
import '../../helpers/uuid_helper.dart';
import 'organizations_table.dart';

class PayrollPolicies extends Table {
  TextColumn get idPolicy =>
      text().clientDefault(() => UuidHelper.generate())();
  TextColumn get organizationId =>
      text().references(Organizations, #idOrganization)();
  TextColumn get name => text()();
  TextColumn get payFrequency => text()();
  TextColumn get currency => text().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateHelper.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateHelper.now())();

  @override
  Set<Column> get primaryKey => {idPolicy};
}
