import 'package:drift/drift.dart';
import '../global_status_defaults.dart';
import '../../helpers/date_helper.dart';
import '../../helpers/uuid_helper.dart';
import 'global_statuses_table.dart';

class Users extends Table {
  TextColumn get idUser => text().clientDefault(() => UuidHelper.generate())();
  TextColumn get name => text()();
  TextColumn get firstSurname => text().nullable()();
  TextColumn get secondLastName => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get globalStatusId => text()
      .clientDefault(() => GlobalStatusDefaults.activeId)
      .references(GlobalStatuses, #idGlobalStatus)();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateHelper.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateHelper.now())();

  @override
  Set<Column> get primaryKey => {idUser};
}
