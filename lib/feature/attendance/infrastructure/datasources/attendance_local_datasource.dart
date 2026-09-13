import 'package:drift/drift.dart';
import 'package:mobile_orvexis/core/database/app_database.dart';
import 'package:mobile_orvexis/core/database/global_status_defaults.dart';
import 'package:mobile_orvexis/core/helpers/date_helper.dart';
import 'package:mobile_orvexis/core/helpers/uuid_helper.dart';
import 'package:mobile_orvexis/feature/attendance/domain/entities/attendance_employee.dart';
import 'package:mobile_orvexis/feature/attendance/domain/entities/attendance_entry_input.dart';

class AttendanceLocalDataSource {
  const AttendanceLocalDataSource(this._database);

  final AppDatabase _database;

  Future<List<AttendanceEmployee>> getDailyAttendance({
    required String organizationId,
    required String projectId,
    required DateTime workDate,
  }) async {
    final date = DateHelper.startOfDay(workDate);
    final rows = await _database
        .customSelect(
          '''
      SELECT
        ou.id_org_user AS org_user_id,
        u.name AS user_name,
        u.first_surname AS user_first_surname,
        u.second_last_name AS user_second_last_name,
        ae.check_in_at AS check_in_at,
        ae.check_out_at AS check_out_at,
        ae.minutes_worked AS minutes_worked,
        ae.notes AS notes
      FROM work_unit_assignments wua
      INNER JOIN org_users ou ON ou.id_org_user = wua.org_user_id
      INNER JOIN users u ON u.id_user = ou.user_id
      LEFT JOIN attendance_events ae
        ON ae.org_user_id = wua.org_user_id
       AND ae.work_unit_id = wua.work_unit_id
       AND ae.work_date = ?
      WHERE wua.organization_id = ?
        AND wua.work_unit_id = ?
        AND wua.global_status_id = ?
        AND u.global_status_id = ?
      ORDER BY u.name ASC, u.first_surname ASC
      ''',
          variables: [
            Variable.withDateTime(date),
            Variable.withString(organizationId),
            Variable.withString(projectId),
            Variable.withString(GlobalStatusDefaults.activeId),
            Variable.withString(GlobalStatusDefaults.activeId),
          ],
          readsFrom: {
            _database.workUnitAssignments,
            _database.orgUsers,
            _database.users,
            _database.attendanceEvents,
          },
        )
        .get();

    return rows
        .map((row) {
          final name = _fullName(
            row.read<String>('user_name'),
            row.read<String?>('user_first_surname'),
            row.read<String?>('user_second_last_name'),
          );
          return AttendanceEmployee(
            orgUserId: row.read<String>('org_user_id'),
            name: name,
            initials: _initials(name),
            checkInAt: row.read<DateTime?>('check_in_at'),
            checkOutAt: row.read<DateTime?>('check_out_at'),
            minutesWorked: row.read<int?>('minutes_worked'),
            notes: row.read<String?>('notes'),
          );
        })
        .toList(growable: false);
  }

  Future<void> saveDailyAttendance({
    required String organizationId,
    required String projectId,
    required DateTime workDate,
    required List<AttendanceEntryInput> entries,
  }) async {
    final date = DateHelper.startOfDay(workDate);
    final presentStatusId = await _resolvePresentStatusId(organizationId);

    await _database.transaction(() async {
      for (final entry in entries) {
        if (entry.checkInAt == null && entry.checkOutAt == null) continue;
        if (entry.checkOutAt != null && entry.checkInAt == null) {
          throw Exception('Registra primero la hora de entrada.');
        }
        if (entry.checkInAt != null &&
            entry.checkOutAt != null &&
            entry.checkOutAt!.isBefore(entry.checkInAt!)) {
          throw Exception(
            'La hora de salida no puede ser anterior a la entrada.',
          );
        }

        final existing =
            await (_database.select(_database.attendanceEvents)..where(
                  (tbl) =>
                      tbl.organizationId.equals(organizationId) &
                      tbl.workUnitId.equals(projectId) &
                      tbl.orgUserId.equals(entry.orgUserId) &
                      tbl.workDate.equals(date),
                ))
                .getSingleOrNull();
        final minutes = entry.checkInAt != null && entry.checkOutAt != null
            ? entry.checkOutAt!.difference(entry.checkInAt!).inMinutes
            : null;

        if (existing == null) {
          await _database
              .into(_database.attendanceEvents)
              .insert(
                AttendanceEventsCompanion(
                  idAttendance: Value(UuidHelper.generate()),
                  organizationId: Value(organizationId),
                  orgUserId: Value(entry.orgUserId),
                  workUnitId: Value(projectId),
                  workDate: Value(date),
                  checkInAt: Value(entry.checkInAt),
                  checkOutAt: Value(entry.checkOutAt),
                  minutesWorked: Value(minutes),
                  notes: Value(_emptyToNull(entry.notes)),
                  statusId: Value(presentStatusId),
                ),
              );
        } else {
          await (_database.update(
                _database.attendanceEvents,
              )..where((tbl) => tbl.idAttendance.equals(existing.idAttendance)))
              .write(
                AttendanceEventsCompanion(
                  checkInAt: Value(entry.checkInAt),
                  checkOutAt: Value(entry.checkOutAt),
                  minutesWorked: Value(minutes),
                  notes: Value(_emptyToNull(entry.notes)),
                  statusId: Value(presentStatusId),
                ),
              );
        }
      }
    });
  }

  Future<String> _resolvePresentStatusId(String organizationId) async {
    final existing =
        await (_database.select(_database.statuses)..where(
              (tbl) =>
                  tbl.organizationId.equals(organizationId) &
                  tbl.entity.equals('attendance') &
                  tbl.code.equals('present'),
            ))
            .getSingleOrNull();
    if (existing != null) return existing.idStatus;

    final id = UuidHelper.generate();
    await _database
        .into(_database.statuses)
        .insert(
          StatusesCompanion(
            idStatus: Value(id),
            organizationId: Value(organizationId),
            entity: const Value('attendance'),
            code: const Value('present'),
            name: const Value('Presente'),
            sortOrder: const Value(1),
          ),
        );
    return id;
  }

  String _fullName(String name, String? firstSurname, String? secondSurname) =>
      [name, firstSurname, secondSurname]
          .whereType<String>()
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .join(' ');

  String _initials(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'NA';
    return parts.length == 1
        ? parts.first.substring(0, 1).toUpperCase()
        : '${parts.first.substring(0, 1)}${parts[1].substring(0, 1)}'
              .toUpperCase();
  }

  String? _emptyToNull(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }
}
