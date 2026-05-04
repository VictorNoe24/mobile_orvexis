import 'package:drift/drift.dart';
import 'package:mobile_orvexis/core/database/app_database.dart';
import 'package:mobile_orvexis/core/database/global_status_defaults.dart';
import 'package:mobile_orvexis/core/helpers/date_helper.dart';
import 'package:mobile_orvexis/core/helpers/uuid_helper.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/create_employee_input.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/employee_compensation_form_data.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/employee.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/employee_form_data.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/employee_filter.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/employees_page.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/update_employee_compensation_input.dart';

class EmployeesLocalDataSource {
  const EmployeesLocalDataSource(this._database);

  final AppDatabase _database;

  Future<List<String>> getRoleNames({required String organizationId}) async {
    final rows =
        await (_database.select(_database.roles)..where(
              (tbl) =>
                  tbl.organizationId.equals(organizationId) &
                  tbl.globalStatusId.equals(GlobalStatusDefaults.activeId),
            ))
            .get();

    final seen = <String>{};
    final roleNames = <String>[];

    for (final row in rows) {
      final normalizedKey = row.name.trim().toLowerCase();
      if (normalizedKey.isEmpty || seen.contains(normalizedKey)) continue;
      seen.add(normalizedKey);
      roleNames.add(row.name.trim());
    }

    roleNames.sort((a, b) => a.compareTo(b));
    return roleNames;
  }

  Future<EmployeesPage> getEmployees({
    required String organizationId,
    required String query,
    required EmployeeFilter filter,
    required int page,
    required int pageSize,
  }) async {
    final employeeRows = await _database
        .customSelect(
          '''
      SELECT
        u.id_user AS user_id,
        u.name AS user_name,
        u.first_surname AS user_first_surname,
        u.second_last_name AS user_second_last_name,
        u.global_status_id AS user_global_status_id,
        CAST(COALESCE(ou.joined_at, u.created_at) AS TEXT) AS start_date,
        ou.id_org_user AS org_user_id,
        (
          SELECT r.name
          FROM org_user_roles our
          INNER JOIN roles r ON r.id_role = our.role_id
          WHERE our.org_user_id = ou.id_org_user
          ORDER BY our.assigned_at DESC, our.created_at DESC
          LIMIT 1
        ) AS role_name
      FROM org_users ou
      INNER JOIN users u ON u.id_user = ou.user_id
      WHERE ou.organization_id = ?
      ''',
          variables: [Variable.withString(organizationId)],
          readsFrom: {
            _database.orgUsers,
            _database.users,
            _database.orgUserRoles,
            _database.roles,
          },
        )
        .get();

    final normalizedQuery = query.trim().toLowerCase();
    final mapped =
        employeeRows
            .map((row) {
              final fullName = _composeDisplayNameFromParts(
                row.read<String>('user_name'),
                row.read<String?>('user_first_surname'),
                row.read<String?>('user_second_last_name'),
              );
              return Employee(
                id: row.read<String>('user_id'),
                initials: _buildInitialsFromName(fullName),
                name: fullName,
                role: row.read<String?>('role_name') ?? 'Sin rol',
                startDate: _formatStoredDate(row.read<String?>('start_date')),
                isActive:
                    row.read<String>('user_global_status_id') ==
                    GlobalStatusDefaults.activeId,
              );
            })
            .where((employee) {
              final matchesFilter = switch (filter) {
                EmployeeFilter.all => true,
                EmployeeFilter.active => employee.isActive,
                EmployeeFilter.inactive => !employee.isActive,
              };

              final matchesQuery =
                  normalizedQuery.isEmpty ||
                  employee.name.toLowerCase().contains(normalizedQuery) ||
                  employee.role.toLowerCase().contains(normalizedQuery);

              return matchesFilter && matchesQuery;
            })
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    final start = page * pageSize;
    if (start >= mapped.length) {
      return const EmployeesPage(items: [], hasMore: false);
    }

    final end = (start + pageSize).clamp(0, mapped.length);
    return EmployeesPage(
      items: mapped.sublist(start, end),
      hasMore: end < mapped.length,
    );
  }

  Future<EmployeeFormData> getEmployeeById({
    required String organizationId,
    required String employeeId,
  }) async {
    final relation = await _getEmployeeRecord(
      organizationId: organizationId,
      userId: employeeId,
    );

    if (relation == null) {
      throw Exception('No se encontro el empleado solicitado.');
    }

    return EmployeeFormData(
      employeeId: relation.userId,
      name: relation.name,
      firstSurname: relation.firstSurname ?? '',
      secondSurname: relation.secondSurname,
      email: relation.email ?? '',
      phone: relation.phone ?? '',
      roleName: relation.roleName ?? 'Sin rol',
      isActive: relation.globalStatusId == GlobalStatusDefaults.activeId,
    );
  }

  Future<void> createEmployee({
    required String organizationId,
    required CreateEmployeeInput input,
  }) async {
    final userId = UuidHelper.generate();
    final orgUserId = UuidHelper.generate();

    await _database.transaction(() async {
      await _database.usersDao.insertUser(
        UsersCompanion(
          idUser: Value(userId),
          name: Value(input.name.trim()),
          firstSurname: Value(input.firstSurname.trim()),
          secondLastName: Value(_nullIfEmpty(input.secondSurname)),
          email: Value(input.email.trim().toLowerCase()),
          phone: Value(input.phone.trim()),
          globalStatusId: Value(
            input.isActive
                ? GlobalStatusDefaults.activeId
                : GlobalStatusDefaults.inactiveId,
          ),
        ),
      );

      await _database.orgUsersDao.insertRelation(
        OrgUsersCompanion(
          idOrgUser: Value(orgUserId),
          organizationId: Value(organizationId),
          userId: Value(userId),
          joinedAt: Value(DateTime.now()),
        ),
      );

      final roleId = await _resolveRoleId(
        organizationId: organizationId,
        roleName: input.roleName,
      );

      await _database
          .into(_database.orgUserRoles)
          .insert(
            OrgUserRolesCompanion(
              idOrgUserRole: Value(UuidHelper.generate()),
              orgUserId: Value(orgUserId),
              roleId: Value(roleId),
              assignedAt: Value(DateTime.now()),
            ),
          );
    });
  }

  Future<void> updateEmployee({
    required String organizationId,
    required String employeeId,
    required CreateEmployeeInput input,
  }) async {
    final relation = await _getEmployeeRecord(
      organizationId: organizationId,
      userId: employeeId,
    );

    if (relation == null) {
      throw Exception('No se encontro el empleado solicitado.');
    }

    final normalizedEmail = input.email.trim().toLowerCase();
    final existingUserId = await _findUserIdByEmail(normalizedEmail);
    if (existingUserId != null && existingUserId != employeeId) {
      throw Exception('Ya existe otro usuario con ese correo.');
    }

    await _database.transaction(() async {
      final affectedRows =
          await (_database.update(
            _database.users,
          )..where((tbl) => tbl.idUser.equals(employeeId))).write(
            UsersCompanion(
              name: Value(input.name.trim()),
              firstSurname: Value(input.firstSurname.trim()),
              secondLastName: Value(_nullIfEmpty(input.secondSurname)),
              email: Value(normalizedEmail),
              phone: Value(input.phone.trim()),
              globalStatusId: Value(
                input.isActive
                    ? GlobalStatusDefaults.activeId
                    : GlobalStatusDefaults.inactiveId,
              ),
            ),
          );

      if (affectedRows == 0) {
        throw Exception('No se pudo actualizar el usuario del empleado.');
      }

      final roleId = await _resolveRoleId(
        organizationId: organizationId,
        roleName: input.roleName,
      );

      final currentRoleRelation =
          await (_database.select(_database.orgUserRoles)
                ..where((tbl) => tbl.orgUserId.equals(relation.orgUserId)))
              .getSingleOrNull();

      if (currentRoleRelation == null) {
        await _database
            .into(_database.orgUserRoles)
            .insert(
              OrgUserRolesCompanion(
                idOrgUserRole: Value(UuidHelper.generate()),
                orgUserId: Value(relation.orgUserId),
                roleId: Value(roleId),
                assignedAt: Value(DateTime.now()),
              ),
            );
      } else {
        await (_database.update(_database.orgUserRoles)..where(
              (tbl) =>
                  tbl.idOrgUserRole.equals(currentRoleRelation.idOrgUserRole),
            ))
            .write(
              OrgUserRolesCompanion(
                roleId: Value(roleId),
                assignedAt: Value(DateTime.now()),
              ),
            );
      }

      if (!input.isActive) {
        await (_database.update(_database.workUnitAssignments)..where(
              (tbl) =>
                  tbl.organizationId.equals(organizationId) &
                  tbl.orgUserId.equals(relation.orgUserId) &
                  tbl.globalStatusId.equals(GlobalStatusDefaults.activeId),
            ))
            .write(
              WorkUnitAssignmentsCompanion(
                globalStatusId: Value(GlobalStatusDefaults.inactiveId),
                endDate: Value(DateTime.now()),
              ),
            );
      }
    });
  }

  Future<EmployeeCompensationFormData> getEmployeeCompensation({
    required String organizationId,
    required String employeeId,
  }) async {
    final relation = await _getEmployeeRecord(
      organizationId: organizationId,
      userId: employeeId,
    );

    if (relation == null) {
      throw Exception('No se encontro el empleado solicitado.');
    }

    final contract =
        await (_database.select(_database.employeeContracts)..where(
              (tbl) =>
                  tbl.organizationId.equals(organizationId) &
                  tbl.orgUserId.equals(relation.orgUserId) &
                  tbl.globalStatusId.equals(GlobalStatusDefaults.activeId),
            ))
            .getSingleOrNull();

    if (contract == null) {
      return const EmployeeCompensationFormData(
        payFrequency: 'weekly',
        baseSalary: null,
        dailyRate: null,
        workDaysPerPeriod: 6,
        contractType: 'fixed_salary',
      );
    }

    final policy =
        await (_database.select(_database.payrollPolicies)
              ..where((tbl) => tbl.idPolicy.equals(contract.policyId)))
            .getSingleOrNull();

    final baseSalary = contract.baseSalary;
    final dailyRate = contract.dailyRate;
    final workDays = (baseSalary != null && dailyRate != null && dailyRate > 0)
        ? (baseSalary / dailyRate).round().clamp(1, 31)
        : ((policy?.payFrequency ?? 'weekly') == 'biweekly' ? 12 : 6);

    return EmployeeCompensationFormData(
      contractId: contract.idContract,
      payFrequency: policy?.payFrequency ?? 'weekly',
      baseSalary: baseSalary,
      dailyRate: dailyRate,
      workDaysPerPeriod: workDays,
      contractType: contract.contractType,
    );
  }

  Future<void> updateEmployeeCompensation({
    required String organizationId,
    required String employeeId,
    required UpdateEmployeeCompensationInput input,
  }) async {
    final relation = await _getEmployeeRecord(
      organizationId: organizationId,
      userId: employeeId,
    );

    if (relation == null) {
      throw Exception('No se encontro el empleado solicitado.');
    }

    if (input.baseSalary <= 0) {
      throw Exception('Ingresa un sueldo fijo mayor a cero.');
    }
    if (input.workDaysPerPeriod <= 0) {
      throw Exception('Ingresa los dias laborables del periodo.');
    }

    final dailyRate = input.baseSalary / input.workDaysPerPeriod;

    await _database.transaction(() async {
      final policyId = await _resolvePayrollPolicyId(
        organizationId: organizationId,
        payFrequency: input.payFrequency,
      );

      final existingContract =
          await (_database.select(_database.employeeContracts)..where(
                (tbl) =>
                    tbl.organizationId.equals(organizationId) &
                    tbl.orgUserId.equals(relation.orgUserId) &
                    tbl.globalStatusId.equals(GlobalStatusDefaults.activeId),
              ))
              .getSingleOrNull();

      if (existingContract == null) {
        await _database
            .into(_database.employeeContracts)
            .insert(
              EmployeeContractsCompanion(
                idContract: Value(UuidHelper.generate()),
                organizationId: Value(organizationId),
                orgUserId: Value(relation.orgUserId),
                policyId: Value(policyId),
                contractType: const Value('fixed_salary'),
                baseSalary: Value(input.baseSalary),
                dailyRate: Value(dailyRate),
                hourlyRate: const Value.absent(),
                startDate: Value(DateTime.now()),
              ),
            );
      } else {
        await (_database.update(_database.employeeContracts)..where(
              (tbl) => tbl.idContract.equals(existingContract.idContract),
            ))
            .write(
              EmployeeContractsCompanion(
                policyId: Value(policyId),
                contractType: const Value('fixed_salary'),
                baseSalary: Value(input.baseSalary),
                dailyRate: Value(dailyRate),
                hourlyRate: const Value(null),
                startDate: Value(existingContract.startDate ?? DateTime.now()),
                endDate: const Value(null),
              ),
            );
      }
    });
  }

  Future<_EmployeeRecord?> _getEmployeeRecord({
    required String organizationId,
    required String userId,
  }) async {
    final row = await _database
        .customSelect(
          '''
      SELECT
        ou.id_org_user AS org_user_id,
        u.id_user AS user_id,
        u.name AS user_name,
        u.first_surname AS user_first_surname,
        u.second_last_name AS user_second_last_name,
        u.email AS user_email,
        u.phone AS user_phone,
        u.global_status_id AS user_global_status_id,
        (
          SELECT r.name
          FROM org_user_roles our
          INNER JOIN roles r ON r.id_role = our.role_id
          WHERE our.org_user_id = ou.id_org_user
          ORDER BY our.assigned_at DESC, our.created_at DESC
          LIMIT 1
        ) AS role_name
      FROM org_users ou
      INNER JOIN users u ON u.id_user = ou.user_id
      WHERE ou.organization_id = ? AND ou.user_id = ?
      LIMIT 1
      ''',
          variables: [
            Variable.withString(organizationId),
            Variable.withString(userId),
          ],
          readsFrom: {
            _database.orgUsers,
            _database.users,
            _database.orgUserRoles,
            _database.roles,
          },
        )
        .getSingleOrNull();

    if (row == null) return null;

    return _EmployeeRecord(
      orgUserId: row.read<String>('org_user_id'),
      userId: row.read<String>('user_id'),
      name: row.read<String>('user_name'),
      firstSurname: row.read<String?>('user_first_surname'),
      secondSurname: row.read<String?>('user_second_last_name'),
      email: row.read<String?>('user_email'),
      phone: row.read<String?>('user_phone'),
      globalStatusId: row.read<String>('user_global_status_id'),
      roleName: row.read<String?>('role_name'),
    );
  }

  Future<String> _resolveRoleId({
    required String organizationId,
    required String roleName,
  }) async {
    final normalizedName = roleName.trim();
    final normalizedCode = _normalizeRoleCode(normalizedName);

    final existingRole =
        await (_database.select(_database.roles)..where(
              (tbl) =>
                  tbl.organizationId.equals(organizationId) &
                  (tbl.code.equals(normalizedCode) |
                      tbl.name.equals(normalizedName)),
            ))
            .getSingleOrNull();

    if (existingRole != null) {
      return existingRole.idRole;
    }

    final roleId = UuidHelper.generate();
    await _database
        .into(_database.roles)
        .insert(
          RolesCompanion(
            idRole: Value(roleId),
            organizationId: Value(organizationId),
            code: Value(normalizedCode),
            name: Value(normalizedName),
            isSystem: const Value(false),
          ),
        );
    return roleId;
  }

  Future<String?> _findUserIdByEmail(String normalizedEmail) async {
    final row = await _database
        .customSelect(
          '''
      SELECT id_user
      FROM users
      WHERE email = ?
      LIMIT 1
      ''',
          variables: [Variable.withString(normalizedEmail)],
          readsFrom: {_database.users},
        )
        .getSingleOrNull();

    return row?.read<String>('id_user');
  }

  Future<String> _resolvePayrollPolicyId({
    required String organizationId,
    required String payFrequency,
  }) async {
    final normalizedFrequency = payFrequency.trim().toLowerCase();

    final existing =
        await (_database.select(_database.payrollPolicies)..where(
              (tbl) =>
                  tbl.organizationId.equals(organizationId) &
                  tbl.payFrequency.equals(normalizedFrequency),
            ))
            .getSingleOrNull();

    if (existing != null) {
      return existing.idPolicy;
    }

    final policyId = UuidHelper.generate();
    await _database
        .into(_database.payrollPolicies)
        .insert(
          PayrollPoliciesCompanion(
            idPolicy: Value(policyId),
            organizationId: Value(organizationId),
            name: Value(
              normalizedFrequency == 'biweekly'
                  ? 'Nomina quincenal'
                  : 'Nomina semanal',
            ),
            payFrequency: Value(normalizedFrequency),
            currency: const Value('MXN'),
            isDefault: const Value(false),
          ),
        );

    return policyId;
  }

  String _normalizeRoleCode(String roleName) {
    return roleName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  String _composeDisplayNameFromParts(
    String name,
    String? firstSurname,
    String? secondSurname,
  ) {
    return [
      name,
      firstSurname,
      secondSurname,
    ].where((part) => part != null && part.trim().isNotEmpty).join(' ');
  }

  String _buildInitialsFromName(String fullName) {
    final parts = fullName.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return 'EM';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _formatStoredDate(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) return '';

    final trimmed = rawValue.trim();
    final parsedDate = _parseStoredDate(trimmed);

    return DateHelper.formatDate(parsedDate);
  }

  DateTime? _parseStoredDate(String rawValue) {
    if (RegExp(r'^\d+$').hasMatch(rawValue)) {
      final epochValue = int.parse(rawValue);
      final normalizedEpoch = rawValue.length <= 10
          ? epochValue * 1000
          : epochValue;
      return DateTime.fromMillisecondsSinceEpoch(normalizedEpoch);
    }

    final normalized = rawValue.contains(' ') && !rawValue.contains('T')
        ? rawValue.replaceFirst(' ', 'T')
        : rawValue;
    return DateTime.tryParse(normalized);
  }

  String? _nullIfEmpty(String? value) {
    if (value == null) return null;
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
}

class _EmployeeRecord {
  const _EmployeeRecord({
    required this.orgUserId,
    required this.userId,
    required this.name,
    required this.firstSurname,
    required this.secondSurname,
    required this.email,
    required this.phone,
    required this.globalStatusId,
    required this.roleName,
  });

  final String orgUserId;
  final String userId;
  final String name;
  final String? firstSurname;
  final String? secondSurname;
  final String? email;
  final String? phone;
  final String globalStatusId;
  final String? roleName;
}
