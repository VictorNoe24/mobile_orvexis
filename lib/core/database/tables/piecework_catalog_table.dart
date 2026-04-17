import 'package:drift/drift.dart';
import '../global_status_defaults.dart';
import '../../helpers/date_helper.dart';
import '../../helpers/uuid_helper.dart';
import 'global_statuses_table.dart';
import 'organizations_table.dart';

class PieceworkCatalog extends Table {
  TextColumn get idPiecework =>
      text().clientDefault(() => UuidHelper.generate())();
  TextColumn get organizationId =>
      text().references(Organizations, #idOrganization)();
  TextColumn get code => text().nullable()();
  TextColumn get description => text()();
  TextColumn get unit => text().nullable()();
  RealColumn get unitPrice => real().nullable()();
  TextColumn get globalStatusId => text()
      .clientDefault(() => GlobalStatusDefaults.activeId)
      .references(GlobalStatuses, #idGlobalStatus)();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateHelper.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateHelper.now())();

  @override
  Set<Column> get primaryKey => {idPiecework};
}
