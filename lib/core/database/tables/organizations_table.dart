import 'package:drift/drift.dart';
import '../../helpers/date_helper.dart';
import '../../helpers/uuid_helper.dart';

class Organizations extends Table {
  TextColumn get idOrganization =>
      text().clientDefault(() => UuidHelper.generate())();
  TextColumn get name => text()();
  TextColumn get taxId => text().nullable()();
  TextColumn get timezone => text().nullable()();
  TextColumn get logoUrl => text().nullable()();
  TextColumn get brandColor => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateHelper.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateHelper.now())();

  @override
  Set<Column> get primaryKey => {idOrganization};
}
