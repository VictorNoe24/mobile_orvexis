import 'package:drift/drift.dart';
import '../global_status_defaults.dart';
import '../../helpers/date_helper.dart';
import '../../helpers/uuid_helper.dart';
import 'global_statuses_table.dart';
import 'organizations_table.dart';

class Roles extends Table {
  TextColumn get idRole => text().clientDefault(() => UuidHelper.generate())();
  TextColumn get organizationId =>
      text().references(Organizations, #idOrganization)();
  TextColumn get code => text()();
  TextColumn get name => text()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  TextColumn get globalStatusId => text()
      .clientDefault(() => GlobalStatusDefaults.activeId)
      .references(GlobalStatuses, #idGlobalStatus)();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateHelper.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateHelper.now())();

  @override
  Set<Column> get primaryKey => {idRole};
}
