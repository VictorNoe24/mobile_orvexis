import 'package:drift/drift.dart';
import '../../helpers/date_helper.dart';
import '../../helpers/uuid_helper.dart';

class GlobalStatuses extends Table {
  TextColumn get idGlobalStatus =>
      text().clientDefault(() => UuidHelper.generate())();
  TextColumn get entity => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get category => text().nullable()();
  IntColumn get sortOrder => integer().nullable()();
  BoolColumn get isTerminal => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateHelper.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateHelper.now())();

  @override
  Set<Column> get primaryKey => {idGlobalStatus};
}
