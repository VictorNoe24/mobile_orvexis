import 'package:drift/drift.dart';
import 'organizations_table.dart';
import 'users_table.dart';

class OrgUsers extends Table {
  TextColumn get idOrgUser => text()();

  TextColumn get organizationId =>
      text().references(Organizations, #idOrganization)();

  TextColumn get userId =>
      text().references(Users, #idUser)();

  DateTimeColumn get joinedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {idOrgUser};
}