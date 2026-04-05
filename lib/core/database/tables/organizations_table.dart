import 'package:drift/drift.dart';

class Organizations extends Table {
  TextColumn get idOrganization => text()();
  TextColumn get name => text()();
  TextColumn get taxId => text().nullable()();
  TextColumn get timezone => text().nullable()();
  TextColumn get logoUrl => text().nullable()();
  TextColumn get brandColor => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {idOrganization};
}