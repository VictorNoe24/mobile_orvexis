import 'package:drift/drift.dart';
import '../../helpers/date_helper.dart';
import '../../helpers/uuid_helper.dart';
import 'organizations_table.dart';
import 'users_table.dart';

class OrgUsers extends Table {
  TextColumn get idOrgUser =>
      text().clientDefault(() => UuidHelper.generate())();

  TextColumn get organizationId =>
      text().references(Organizations, #idOrganization)();

  TextColumn get userId => text().references(Users, #idUser)();

  DateTimeColumn get joinedAt => dateTime().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateHelper.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateHelper.now())();

  @override
  Set<Column> get primaryKey => {idOrgUser};
}
