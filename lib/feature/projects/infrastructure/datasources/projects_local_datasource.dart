import 'dart:io';

import 'package:drift/drift.dart';
import 'package:mobile_orvexis/core/database/app_database.dart';
import 'package:mobile_orvexis/core/database/global_status_defaults.dart';
import 'package:mobile_orvexis/core/helpers/uuid_helper.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/create_project_input.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_activity_item.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_assignable_employee.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_assigned_employee.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_detail.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_form_data.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_item.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ProjectsLocalDataSource {
  const ProjectsLocalDataSource(this._database);

  final AppDatabase _database;

  Future<List<ProjectItem>> getProjects({
    required String organizationId,
    required String query,
  }) async {
    final rows = await _database
        .customSelect(
          '''
      SELECT
        wu.id_work_unit AS project_id,
        wu.code AS project_code,
        wu.name AS project_name,
        wu.location AS project_location,
        wu.image_path AS project_image_path,
        CAST(wu.start_date AS TEXT) AS project_start_date,
        CAST(wu.end_date AS TEXT) AS project_end_date,
        s.code AS status_code,
        s.name AS status_name
      FROM work_units wu
      INNER JOIN statuses s ON s.id_status = wu.status_id
      WHERE wu.organization_id = ?
      ORDER BY wu.created_at DESC, wu.name ASC
      ''',
          variables: [Variable.withString(organizationId)],
          readsFrom: {_database.workUnits, _database.statuses},
        )
        .get();

    final normalizedQuery = query.trim().toLowerCase();

    return rows
        .map((row) {
          final name = row.read<String>('project_name');
          final location =
              row.read<String?>('project_location') ?? 'Sin ubicacion';
          return ProjectItem(
            id: row.read<String>('project_id'),
            code: row.read<String?>('project_code'),
            name: name,
            location: location,
            dateLabel: _buildDateLabel(
              row.read<String?>('project_start_date'),
              row.read<String?>('project_end_date'),
            ),
            status: _mapStatusCode(row.read<String>('status_code')),
            statusLabel: row.read<String>('status_name'),
            imagePath: row.read<String?>('project_image_path'),
          );
        })
        .where((project) {
          if (normalizedQuery.isEmpty) {
            return true;
          }

          return project.name.toLowerCase().contains(normalizedQuery) ||
              project.location.toLowerCase().contains(normalizedQuery) ||
              (project.code?.toLowerCase().contains(normalizedQuery) ?? false);
        })
        .toList(growable: false);
  }

  Future<void> createProject({
    required String organizationId,
    required CreateProjectInput input,
  }) async {
    final normalizedName = input.name.trim();
    final normalizedLocation = input.location.trim();
    if (normalizedName.isEmpty) {
      throw Exception('Ingresa el nombre del proyecto.');
    }
    if (normalizedLocation.isEmpty) {
      throw Exception('Ingresa la ubicacion del proyecto.');
    }
    if (input.startDate != null &&
        input.endDate != null &&
        input.endDate!.isBefore(input.startDate!)) {
      throw Exception(
        'La fecha de fin no puede ser anterior a la fecha de inicio.',
      );
    }

    final projectId = UuidHelper.generate();

    await _database.transaction(() async {
      await _ensureProjectNameIsUnique(
        organizationId: organizationId,
        projectName: normalizedName,
      );

      final statusId = await _resolveStatusId(
        organizationId: organizationId,
        statusCode: input.statusCode,
      );

      final storedImagePath = input.imageSourcePath == null
          ? null
          : await _copyProjectImage(
              projectId: projectId,
              sourcePath: input.imageSourcePath!,
            );

      await _database
          .into(_database.workUnits)
          .insert(
            WorkUnitsCompanion(
              idWorkUnit: Value(projectId),
              organizationId: Value(organizationId),
              code: Value(_normalizeOptional(input.code)),
              name: Value(normalizedName),
              location: Value(normalizedLocation),
              imagePath: Value(storedImagePath),
              startDate: Value(input.startDate),
              endDate: Value(input.endDate),
              statusId: Value(statusId),
            ),
          );
    });
  }

  Future<ProjectFormData> getProjectFormData({
    required String organizationId,
    required String projectId,
  }) async {
    final row =
        await (_database.select(_database.workUnits)..where(
              (tbl) =>
                  tbl.organizationId.equals(organizationId) &
                  tbl.idWorkUnit.equals(projectId),
            ))
            .getSingleOrNull();

    if (row == null) {
      throw Exception('No se encontro la obra solicitada.');
    }

    final status = await (_database.select(
      _database.statuses,
    )..where((tbl) => tbl.idStatus.equals(row.statusId))).getSingleOrNull();

    if (status == null) {
      throw Exception('No se encontro el estado de la obra.');
    }

    return ProjectFormData(
      id: row.idWorkUnit,
      name: row.name,
      code: row.code,
      location: row.location ?? '',
      startDate: row.startDate,
      endDate: row.endDate,
      statusCode: status.code,
      imagePath: row.imagePath,
    );
  }

  Future<void> updateProject({
    required String organizationId,
    required String projectId,
    required CreateProjectInput input,
  }) async {
    final current =
        await (_database.select(_database.workUnits)..where(
              (tbl) =>
                  tbl.organizationId.equals(organizationId) &
                  tbl.idWorkUnit.equals(projectId),
            ))
            .getSingleOrNull();

    if (current == null) {
      throw Exception('No se encontro la obra solicitada.');
    }

    final normalizedName = input.name.trim();
    final normalizedLocation = input.location.trim();
    if (normalizedName.isEmpty) {
      throw Exception('Ingresa el nombre del proyecto.');
    }
    if (normalizedLocation.isEmpty) {
      throw Exception('Ingresa la ubicacion del proyecto.');
    }
    if (input.startDate != null &&
        input.endDate != null &&
        input.endDate!.isBefore(input.startDate!)) {
      throw Exception(
        'La fecha de fin no puede ser anterior a la fecha de inicio.',
      );
    }

    await _database.transaction(() async {
      await _ensureProjectNameIsUnique(
        organizationId: organizationId,
        projectName: normalizedName,
        excludingProjectId: projectId,
      );

      final statusId = await _resolveStatusId(
        organizationId: organizationId,
        statusCode: input.statusCode,
      );

      final imagePath = await _resolveUpdatedImagePath(
        projectId: projectId,
        currentImagePath: current.imagePath,
        newImageSourcePath: input.imageSourcePath,
      );

      await (_database.update(
        _database.workUnits,
      )..where((tbl) => tbl.idWorkUnit.equals(projectId))).write(
        WorkUnitsCompanion(
          code: Value(_normalizeOptional(input.code)),
          name: Value(normalizedName),
          location: Value(normalizedLocation),
          imagePath: Value(imagePath),
          startDate: Value(input.startDate),
          endDate: Value(input.endDate),
          statusId: Value(statusId),
        ),
      );
    });
  }

  Future<ProjectDetail> getProjectDetail({
    required String organizationId,
    required String projectId,
  }) async {
    final row =
        await (_database.select(_database.workUnits)..where(
              (tbl) =>
                  tbl.organizationId.equals(organizationId) &
                  tbl.idWorkUnit.equals(projectId),
            ))
            .getSingleOrNull();

    if (row == null) {
      throw Exception('No se encontro la obra solicitada.');
    }

    final status = await (_database.select(
      _database.statuses,
    )..where((tbl) => tbl.idStatus.equals(row.statusId))).getSingleOrNull();

    if (status == null) {
      throw Exception('No se encontro el estado de la obra.');
    }

    final assignedEmployees = await getAssignedEmployees(
      organizationId: organizationId,
      projectId: projectId,
    );

    return ProjectDetail(
      id: row.idWorkUnit,
      name: row.name,
      location: row.location?.trim().isNotEmpty == true
          ? row.location!.trim()
          : 'Sin ubicacion registrada',
      status: _mapStatusCode(status.code),
      statusLabel: status.name,
      imagePath: row.imagePath,
      code: row.code,
      progressPercent: _computeProgressPercent(
        statusCode: status.code,
        startDate: row.startDate,
        endDate: row.endDate,
      ),
      startDateLabel: row.startDate == null
          ? 'Sin definir'
          : _formatDate(row.startDate!),
      endDateLabel: row.endDate == null
          ? 'Sin definir'
          : _formatDate(row.endDate!),
      createdAtLabel: _formatDate(row.createdAt),
      assignedEmployeesCount: assignedEmployees.length,
      activities: _buildActivities(
        projectCreatedAt: row.createdAt,
        startDate: row.startDate,
        endDate: row.endDate,
        assignedEmployees: assignedEmployees,
      ),
    );
  }

  Future<List<ProjectAssignedEmployee>> getAssignedEmployees({
    required String organizationId,
    required String projectId,
  }) async {
    final rows = await _database
        .customSelect(
          '''
      SELECT
        wua.id_assignment AS assignment_id,
        wua.org_user_id AS org_user_id,
        u.id_user AS user_id,
        u.name AS user_name,
        u.first_surname AS user_first_surname,
        u.second_last_name AS user_second_last_name,
        r.name AS role_name,
        CAST(COALESCE(wua.start_date, wua.created_at) AS TEXT) AS assigned_at
      FROM work_unit_assignments wua
      INNER JOIN org_users ou ON ou.id_org_user = wua.org_user_id
      INNER JOIN users u ON u.id_user = ou.user_id
      LEFT JOIN org_user_roles our ON our.org_user_id = ou.id_org_user
      LEFT JOIN roles r ON r.id_role = our.role_id
      WHERE wua.organization_id = ?
        AND wua.work_unit_id = ?
        AND wua.global_status_id = ?
      ORDER BY wua.created_at DESC
      ''',
          variables: [
            Variable.withString(organizationId),
            Variable.withString(projectId),
            Variable.withString(GlobalStatusDefaults.activeId),
          ],
          readsFrom: {
            _database.workUnitAssignments,
            _database.orgUsers,
            _database.users,
            _database.orgUserRoles,
            _database.roles,
          },
        )
        .get();

    final seen = <String>{};
    final items = <ProjectAssignedEmployee>[];

    for (final row in rows) {
      final orgUserId = row.read<String>('org_user_id');
      if (seen.contains(orgUserId)) {
        continue;
      }
      seen.add(orgUserId);

      final fullName = _composeDisplayNameFromParts(
        row.read<String>('user_name'),
        row.read<String?>('user_first_surname'),
        row.read<String?>('user_second_last_name'),
      );

      items.add(
        ProjectAssignedEmployee(
          assignmentId: row.read<String>('assignment_id'),
          orgUserId: orgUserId,
          userId: row.read<String>('user_id'),
          name: fullName,
          role: row.read<String?>('role_name') ?? 'Sin rol',
          initials: _buildInitialsFromName(fullName),
          assignedLabel: _relativeDateLabel(
            _tryParseDate(row.read<String?>('assigned_at')),
          ),
        ),
      );
    }

    return items;
  }

  Future<List<ProjectAssignableEmployee>> getAssignableEmployees({
    required String organizationId,
    required String projectId,
  }) async {
    final assignedEmployees = await getAssignedEmployees(
      organizationId: organizationId,
      projectId: projectId,
    );
    final assignedIds = assignedEmployees.map((item) => item.orgUserId).toSet();

    final employeeRows = await _database
        .customSelect(
          '''
      SELECT
        ou.id_org_user AS org_user_id,
        u.id_user AS user_id,
        u.name AS user_name,
        u.first_surname AS user_first_surname,
        u.second_last_name AS user_second_last_name,
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
      WHERE ou.organization_id = ?
      ORDER BY u.name ASC, u.first_surname ASC
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

    return employeeRows
        .where(
          (row) =>
              !assignedIds.contains(row.read<String>('org_user_id')) &&
              row.read<String>('user_global_status_id') ==
                  GlobalStatusDefaults.activeId,
        )
        .map((row) {
          final fullName = _composeDisplayNameFromParts(
            row.read<String>('user_name'),
            row.read<String?>('user_first_surname'),
            row.read<String?>('user_second_last_name'),
          );

          return ProjectAssignableEmployee(
            orgUserId: row.read<String>('org_user_id'),
            userId: row.read<String>('user_id'),
            name: fullName,
            role: row.read<String?>('role_name') ?? 'Sin rol',
            initials: _buildInitialsFromName(fullName),
            isActive:
                row.read<String>('user_global_status_id') ==
                GlobalStatusDefaults.activeId,
          );
        })
        .toList(growable: false);
  }

  Future<void> assignEmployeesToProject({
    required String organizationId,
    required String projectId,
    required List<String> orgUserIds,
  }) async {
    final uniqueIds = orgUserIds.toSet().toList(growable: false);
    if (uniqueIds.isEmpty) {
      throw Exception('Selecciona al menos un empleado.');
    }

    await _database.transaction(() async {
      for (final orgUserId in uniqueIds) {
        final existing =
            await (_database.select(_database.workUnitAssignments)..where(
                  (tbl) =>
                      tbl.organizationId.equals(organizationId) &
                      tbl.workUnitId.equals(projectId) &
                      tbl.orgUserId.equals(orgUserId) &
                      tbl.globalStatusId.equals(GlobalStatusDefaults.activeId),
                ))
                .getSingleOrNull();

        if (existing != null) {
          continue;
        }

        await _database
            .into(_database.workUnitAssignments)
            .insert(
              WorkUnitAssignmentsCompanion(
                idAssignment: Value(UuidHelper.generate()),
                organizationId: Value(organizationId),
                workUnitId: Value(projectId),
                orgUserId: Value(orgUserId),
                startDate: Value(DateTime.now()),
              ),
            );
      }
    });
  }

  Future<void> removeEmployeeFromProject({
    required String organizationId,
    required String projectId,
    required String assignmentId,
  }) async {
    final affectedRows =
        await (_database.update(_database.workUnitAssignments)..where(
              (tbl) =>
                  tbl.organizationId.equals(organizationId) &
                  tbl.workUnitId.equals(projectId) &
                  tbl.idAssignment.equals(assignmentId) &
                  tbl.globalStatusId.equals(GlobalStatusDefaults.activeId),
            ))
            .write(
              WorkUnitAssignmentsCompanion(
                globalStatusId: Value(GlobalStatusDefaults.inactiveId),
                endDate: Value(DateTime.now()),
              ),
            );

    if (affectedRows == 0) {
      throw Exception('No se pudo dar de baja al empleado de esta obra.');
    }
  }

  Future<void> _ensureProjectNameIsUnique({
    required String organizationId,
    required String projectName,
    String? excludingProjectId,
  }) async {
    final normalizedName = projectName.toLowerCase();
    final rows = await (_database.select(
      _database.workUnits,
    )..where((tbl) => tbl.organizationId.equals(organizationId))).get();

    for (final row in rows) {
      if (excludingProjectId != null && row.idWorkUnit == excludingProjectId) {
        continue;
      }
      if (row.name.trim().toLowerCase() == normalizedName) {
        throw Exception(
          'Ya existe un proyecto con ese nombre en la organizacion.',
        );
      }
    }
  }

  Future<String> _resolveStatusId({
    required String organizationId,
    required String statusCode,
  }) async {
    final normalizedCode = statusCode.trim().toLowerCase();
    final existing =
        await (_database.select(_database.statuses)..where(
              (tbl) =>
                  tbl.organizationId.equals(organizationId) &
                  tbl.entity.equals('work_unit') &
                  tbl.code.equals(normalizedCode),
            ))
            .getSingleOrNull();

    if (existing != null) {
      return existing.idStatus;
    }

    final statusId = UuidHelper.generate();
    await _database
        .into(_database.statuses)
        .insert(
          StatusesCompanion(
            idStatus: Value(statusId),
            organizationId: Value(organizationId),
            entity: const Value('work_unit'),
            code: Value(normalizedCode),
            name: Value(_statusNameFromCode(normalizedCode)),
            sortOrder: Value(_statusSortOrder(normalizedCode)),
            isTerminal: Value(normalizedCode == 'completed'),
          ),
        );

    return statusId;
  }

  Future<String> _copyProjectImage({
    required String projectId,
    required String sourcePath,
  }) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw Exception('No se encontro la imagen seleccionada.');
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(docsDir.path, 'project_images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final extension = p.extension(sourcePath);
    final targetPath = p.join(
      imagesDir.path,
      '$projectId${extension.isEmpty ? '.jpg' : extension}',
    );

    final copiedFile = await sourceFile.copy(targetPath);
    return copiedFile.path;
  }

  Future<String?> _resolveUpdatedImagePath({
    required String projectId,
    required String? currentImagePath,
    required String? newImageSourcePath,
  }) async {
    if (newImageSourcePath == null) {
      return currentImagePath;
    }

    if (newImageSourcePath.isEmpty) {
      if (currentImagePath != null && currentImagePath.isNotEmpty) {
        final currentFile = File(currentImagePath);
        if (await currentFile.exists()) {
          await currentFile.delete();
        }
      }
      return null;
    }

    if (currentImagePath != null && currentImagePath.isNotEmpty) {
      final currentFile = File(currentImagePath);
      if (await currentFile.exists()) {
        await currentFile.delete();
      }
    }

    return _copyProjectImage(
      projectId: projectId,
      sourcePath: newImageSourcePath,
    );
  }

  ProjectStatusCode _mapStatusCode(String code) {
    switch (code.trim().toLowerCase()) {
      case 'completed':
        return ProjectStatusCode.completed;
      case 'in_progress':
        return ProjectStatusCode.inProgress;
      default:
        return ProjectStatusCode.active;
    }
  }

  String _statusNameFromCode(String code) {
    switch (code) {
      case 'completed':
        return 'Finalizado';
      case 'in_progress':
        return 'En curso';
      default:
        return 'Activo';
    }
  }

  int _statusSortOrder(String code) {
    switch (code) {
      case 'active':
        return 1;
      case 'in_progress':
        return 2;
      case 'completed':
        return 3;
      default:
        return 99;
    }
  }

  String _buildDateLabel(String? startDateRaw, String? endDateRaw) {
    final startDate = _tryParseDate(startDateRaw);
    final endDate = _tryParseDate(endDateRaw);
    final startLabel = startDate == null ? null : _formatDate(startDate);
    final endLabel = endDate == null ? null : _formatDate(endDate);

    if (startLabel != null && endLabel != null) {
      return '$startLabel - $endLabel';
    }
    if (startLabel != null) {
      return 'Inicio $startLabel';
    }
    if (endLabel != null) {
      return 'Cierre $endLabel';
    }
    return 'Sin fechas definidas';
  }

  DateTime? _tryParseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    return DateTime.tryParse(raw);
  }

  String _formatDate(DateTime date) {
    const monthNames = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    final month = monthNames[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    return '$day $month ${date.year}';
  }

  String? _normalizeOptional(String? value) {
    if (value == null) {
      return null;
    }
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  int _computeProgressPercent({
    required String statusCode,
    required DateTime? startDate,
    required DateTime? endDate,
  }) {
    final normalizedStatus = statusCode.trim().toLowerCase();
    if (normalizedStatus == 'completed') {
      return 100;
    }

    if (startDate == null || endDate == null) {
      return normalizedStatus == 'in_progress' ? 55 : 20;
    }

    final now = DateTime.now();
    if (now.isBefore(startDate)) {
      return 0;
    }
    if (now.isAfter(endDate)) {
      return 100;
    }

    final total = endDate.difference(startDate).inDays;
    if (total <= 0) {
      return 100;
    }

    final elapsed = now.difference(startDate).inDays.clamp(0, total);
    return ((elapsed / total) * 100).round().clamp(0, 100);
  }

  List<ProjectActivityItem> _buildActivities({
    required DateTime projectCreatedAt,
    required DateTime? startDate,
    required DateTime? endDate,
    required List<ProjectAssignedEmployee> assignedEmployees,
  }) {
    final items = <ProjectActivityItem>[
      ProjectActivityItem(
        title: 'Obra registrada',
        caption: _relativeDateLabel(projectCreatedAt),
        detail: 'El proyecto fue guardado en la base local.',
        isHighlighted: true,
      ),
    ];

    if (startDate != null) {
      items.add(
        ProjectActivityItem(
          title: 'Inicio programado',
          caption: _relativeDateLabel(startDate),
          detail: _formatDate(startDate),
        ),
      );
    }

    if (endDate != null) {
      items.add(
        ProjectActivityItem(
          title: 'Cierre estimado',
          caption: _relativeDateLabel(endDate),
          detail: _formatDate(endDate),
        ),
      );
    }

    for (final employee in assignedEmployees) {
      items.add(
        ProjectActivityItem(
          title: 'Empleado asignado',
          caption: employee.assignedLabel,
          detail: '${employee.name} · ${employee.role}',
        ),
      );
    }

    return items;
  }

  String _composeDisplayNameFromParts(
    String name,
    String? firstSurname,
    String? secondSurname,
  ) {
    return [
      name.trim(),
      firstSurname?.trim() ?? '',
      secondSurname?.trim() ?? '',
    ].where((part) => part.isNotEmpty).join(' ');
  }

  String _buildInitialsFromName(String fullName) {
    final parts = fullName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return 'NA';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  String _relativeDateLabel(DateTime? date) {
    if (date == null) {
      return 'Sin fecha';
    }

    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    final absoluteDifference = difference.abs();

    if (difference == 0) {
      return 'Hoy';
    }
    if (difference == -1) {
      return 'Ayer';
    }
    if (difference == 1) {
      return 'Mañana';
    }
    if (difference < 0 && absoluteDifference < 30) {
      return 'Hace $absoluteDifference dias';
    }
    if (difference > 0 && difference < 30) {
      return 'En $difference dias';
    }
    return _formatDate(date);
  }
}
