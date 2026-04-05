import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/organizations_table.dart';

part 'organizations_dao.g.dart';

@DriftAccessor(tables: [Organizations])
class OrganizationsDao extends DatabaseAccessor<AppDatabase>
    with _$OrganizationsDaoMixin {
  OrganizationsDao(super.db);

  Future<List<Organization>> getAllOrganizations() {
    return select(organizations).get();
  }

  Stream<List<Organization>> watchAllOrganizations() {
    return select(organizations).watch();
  }

  Future<Organization?> getOrganizationById(String id) {
    return (select(organizations)
          ..where((tbl) => tbl.idOrganization.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertOrganization(OrganizationsCompanion entity) {
    return into(organizations).insert(entity);
  }

  Future<bool> updateOrganization(Organization entity) {
    return update(organizations).replace(entity);
  }

  Future<int> deleteOrganizationById(String id) {
    return (delete(organizations)
          ..where((tbl) => tbl.idOrganization.equals(id)))
        .go();
  }
}