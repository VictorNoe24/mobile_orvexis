import 'package:drift/drift.dart';
import '../../helpers/date_helper.dart';
import '../../helpers/uuid_helper.dart';
import 'organizations_table.dart';
import 'statuses_table.dart';

class WorkUnits extends Table {
  TextColumn get idWorkUnit =>
      text().clientDefault(() => UuidHelper.generate())();
  TextColumn get organizationId =>
      text().references(Organizations, #idOrganization)();
  TextColumn get code => text().nullable()();
  TextColumn get name => text()();
  TextColumn get location => text().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get statusId => text().references(Statuses, #idStatus)();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateHelper.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateHelper.now())();

  @override
  Set<Column> get primaryKey => {idWorkUnit};
}
