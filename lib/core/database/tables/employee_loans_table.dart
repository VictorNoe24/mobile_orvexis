import 'package:drift/drift.dart';
import '../../helpers/date_helper.dart';
import '../../helpers/uuid_helper.dart';
import 'organizations_table.dart';
import 'org_users_table.dart';
import 'statuses_table.dart';

class EmployeeLoans extends Table {
  TextColumn get idLoan => text().clientDefault(() => UuidHelper.generate())();
  TextColumn get organizationId =>
      text().references(Organizations, #idOrganization)();
  TextColumn get orgUserId => text().references(OrgUsers, #idOrgUser)();
  RealColumn get principal => real().nullable()();
  RealColumn get balance => real().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  TextColumn get statusId => text().references(Statuses, #idStatus)();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateHelper.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateHelper.now())();

  @override
  Set<Column> get primaryKey => {idLoan};
}
