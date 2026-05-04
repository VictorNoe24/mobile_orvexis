import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/org_users_table.dart';
import '../tables/users_table.dart';
import '../tables/organizations_table.dart';

part 'org_users_dao.g.dart';

class OrgUserWithDetails {
  final OrgUser orgUser;
  final User user;
  final Organization organization;

  OrgUserWithDetails({
    required this.orgUser,
    required this.user,
    required this.organization,
  });
}

@DriftAccessor(tables: [OrgUsers, Users, Organizations])
class OrgUsersDao extends DatabaseAccessor<AppDatabase>
    with _$OrgUsersDaoMixin {
  OrgUsersDao(super.db);

  Future<List<OrgUser>> getAllRelations() {
    return select(orgUsers).get();
  }

  Stream<List<OrgUser>> watchAllRelations() {
    return select(orgUsers).watch();
  }

  Future<OrgUser?> getRelationById(String id) {
    return (select(
      orgUsers,
    )..where((tbl) => tbl.idOrgUser.equals(id))).getSingleOrNull();
  }

  Future<int> insertRelation(OrgUsersCompanion entity) {
    return into(orgUsers).insert(entity);
  }

  Future<int> deleteRelationById(String id) {
    return (delete(orgUsers)..where((tbl) => tbl.idOrgUser.equals(id))).go();
  }

  Future<List<OrgUserWithDetails>> getUsersByOrganization(
    String organizationId,
  ) async {
    final rows = await customSelect(
      '''
      SELECT
        ou.id_org_user AS ou_id_org_user,
        ou.organization_id AS ou_organization_id,
        ou.user_id AS ou_user_id,
        CAST(ou.joined_at AS TEXT) AS ou_joined_at,
        CAST(ou.created_at AS TEXT) AS ou_created_at,
        CAST(ou.updated_at AS TEXT) AS ou_updated_at,
        u.id_user AS u_id_user,
        u.name AS u_name,
        u.first_surname AS u_first_surname,
        u.second_last_name AS u_second_last_name,
        u.email AS u_email,
        u.phone AS u_phone,
        u.global_status_id AS u_global_status_id,
        CAST(u.created_at AS TEXT) AS u_created_at,
        CAST(u.updated_at AS TEXT) AS u_updated_at,
        o.id_organization AS o_id_organization,
        o.name AS o_name,
        o.tax_id AS o_tax_id,
        o.timezone AS o_timezone,
        o.logo_url AS o_logo_url,
        o.brand_color AS o_brand_color,
        CAST(o.created_at AS TEXT) AS o_created_at,
        CAST(o.updated_at AS TEXT) AS o_updated_at
      FROM org_users ou
      INNER JOIN users u ON u.id_user = ou.user_id
      INNER JOIN organizations o ON o.id_organization = ou.organization_id
      WHERE ou.organization_id = ?
      ''',
      variables: [Variable.withString(organizationId)],
      readsFrom: {orgUsers, users, organizations},
    ).get();

    return rows.map(_mapOrgUserWithDetails).toList();
  }

  Stream<List<OrgUserWithDetails>> watchUsersByOrganization(
    String organizationId,
  ) {
    final query = select(orgUsers).join([
      innerJoin(users, users.idUser.equalsExp(orgUsers.userId)),
      innerJoin(
        organizations,
        organizations.idOrganization.equalsExp(orgUsers.organizationId),
      ),
    ])..where(orgUsers.organizationId.equals(organizationId));

    return query.watch().map((rows) {
      return rows.map((row) {
        return OrgUserWithDetails(
          orgUser: row.readTable(orgUsers),
          user: row.readTable(users),
          organization: row.readTable(organizations),
        );
      }).toList();
    });
  }

  Future<List<OrgUserWithDetails>> getOrganizationsByUser(String userId) async {
    final rows = await customSelect(
      '''
      SELECT
        ou.id_org_user AS ou_id_org_user,
        ou.organization_id AS ou_organization_id,
        ou.user_id AS ou_user_id,
        CAST(ou.joined_at AS TEXT) AS ou_joined_at,
        CAST(ou.created_at AS TEXT) AS ou_created_at,
        CAST(ou.updated_at AS TEXT) AS ou_updated_at,
        u.id_user AS u_id_user,
        u.name AS u_name,
        u.first_surname AS u_first_surname,
        u.second_last_name AS u_second_last_name,
        u.email AS u_email,
        u.phone AS u_phone,
        u.global_status_id AS u_global_status_id,
        CAST(u.created_at AS TEXT) AS u_created_at,
        CAST(u.updated_at AS TEXT) AS u_updated_at,
        o.id_organization AS o_id_organization,
        o.name AS o_name,
        o.tax_id AS o_tax_id,
        o.timezone AS o_timezone,
        o.logo_url AS o_logo_url,
        o.brand_color AS o_brand_color,
        CAST(o.created_at AS TEXT) AS o_created_at,
        CAST(o.updated_at AS TEXT) AS o_updated_at
      FROM org_users ou
      INNER JOIN users u ON u.id_user = ou.user_id
      INNER JOIN organizations o ON o.id_organization = ou.organization_id
      WHERE ou.user_id = ?
      ''',
      variables: [Variable.withString(userId)],
      readsFrom: {orgUsers, users, organizations},
    ).get();

    return rows.map(_mapOrgUserWithDetails).toList();
  }

  Future<OrgUserWithDetails?> getRelationByOrganizationAndUser({
    required String organizationId,
    required String userId,
  }) async {
    final rows = await customSelect(
      '''
      SELECT
        ou.id_org_user AS ou_id_org_user,
        ou.organization_id AS ou_organization_id,
        ou.user_id AS ou_user_id,
        CAST(ou.joined_at AS TEXT) AS ou_joined_at,
        CAST(ou.created_at AS TEXT) AS ou_created_at,
        CAST(ou.updated_at AS TEXT) AS ou_updated_at,
        u.id_user AS u_id_user,
        u.name AS u_name,
        u.first_surname AS u_first_surname,
        u.second_last_name AS u_second_last_name,
        u.email AS u_email,
        u.phone AS u_phone,
        u.global_status_id AS u_global_status_id,
        CAST(u.created_at AS TEXT) AS u_created_at,
        CAST(u.updated_at AS TEXT) AS u_updated_at,
        o.id_organization AS o_id_organization,
        o.name AS o_name,
        o.tax_id AS o_tax_id,
        o.timezone AS o_timezone,
        o.logo_url AS o_logo_url,
        o.brand_color AS o_brand_color,
        CAST(o.created_at AS TEXT) AS o_created_at,
        CAST(o.updated_at AS TEXT) AS o_updated_at
      FROM org_users ou
      INNER JOIN users u ON u.id_user = ou.user_id
      INNER JOIN organizations o ON o.id_organization = ou.organization_id
      WHERE ou.organization_id = ? AND ou.user_id = ?
      LIMIT 1
      ''',
      variables: [
        Variable.withString(organizationId),
        Variable.withString(userId),
      ],
      readsFrom: {orgUsers, users, organizations},
    ).getSingleOrNull();

    if (rows == null) return null;
    return _mapOrgUserWithDetails(rows);
  }

  OrgUserWithDetails _mapOrgUserWithDetails(QueryRow row) {
    return OrgUserWithDetails(
      orgUser: OrgUser(
        idOrgUser: row.read<String>('ou_id_org_user'),
        organizationId: row.read<String>('ou_organization_id'),
        userId: row.read<String>('ou_user_id'),
        joinedAt: _readDateTimeNullable(row, 'ou_joined_at'),
        createdAt: _readDateTime(row, 'ou_created_at'),
        updatedAt: _readDateTime(row, 'ou_updated_at'),
      ),
      user: User(
        idUser: row.read<String>('u_id_user'),
        name: row.read<String>('u_name'),
        firstSurname: row.read<String?>('u_first_surname'),
        secondLastName: row.read<String?>('u_second_last_name'),
        email: row.read<String?>('u_email'),
        phone: row.read<String?>('u_phone'),
        globalStatusId: row.read<String>('u_global_status_id'),
        createdAt: _readDateTime(row, 'u_created_at'),
        updatedAt: _readDateTime(row, 'u_updated_at'),
      ),
      organization: Organization(
        idOrganization: row.read<String>('o_id_organization'),
        name: row.read<String>('o_name'),
        taxId: row.read<String?>('o_tax_id'),
        timezone: row.read<String?>('o_timezone'),
        logoUrl: row.read<String?>('o_logo_url'),
        brandColor: row.read<String?>('o_brand_color'),
        createdAt: _readDateTime(row, 'o_created_at'),
        updatedAt: _readDateTime(row, 'o_updated_at'),
      ),
    );
  }

  DateTime _readDateTime(QueryRow row, String columnName) {
    final rawValue = row.read<String?>(columnName);
    final parsed = _parseDateTime(rawValue);
    if (parsed == null) {
      throw FormatException('No fue posible leer la fecha de $columnName');
    }
    return parsed;
  }

  DateTime? _readDateTimeNullable(QueryRow row, String columnName) {
    final rawValue = row.read<String?>(columnName);
    return _parseDateTime(rawValue);
  }

  DateTime? _parseDateTime(dynamic rawValue) {
    if (rawValue == null) return null;
    if (rawValue is DateTime) return rawValue;
    if (rawValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(rawValue);
    }
    if (rawValue is BigInt) {
      return DateTime.fromMillisecondsSinceEpoch(rawValue.toInt());
    }
    if (rawValue is String) {
      final trimmed = rawValue.trim();
      if (trimmed.isEmpty) return null;

      if (RegExp(r'^\d+$').hasMatch(trimmed)) {
        final epochValue = int.parse(trimmed);
        final normalizedEpoch = trimmed.length <= 10
            ? epochValue * 1000
            : epochValue;
        return DateTime.fromMillisecondsSinceEpoch(normalizedEpoch);
      }

      final normalized = trimmed.contains(' ') && !trimmed.contains('T')
          ? trimmed.replaceFirst(' ', 'T')
          : trimmed;

      return DateTime.tryParse(normalized);
    }
    return null;
  }
}
