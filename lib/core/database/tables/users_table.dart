import 'package:drift/drift.dart';

class Users extends Table {
  TextColumn get idUser => text()();
  TextColumn get name => text()();
  TextColumn get firstSurname => text().nullable()();
  TextColumn get secondLastName => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {idUser};
}