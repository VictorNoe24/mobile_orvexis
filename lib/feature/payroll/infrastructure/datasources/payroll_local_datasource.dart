import 'package:drift/drift.dart';
import 'package:mobile_orvexis/core/database/app_database.dart';
import 'package:mobile_orvexis/core/database/global_status_defaults.dart';
import 'package:mobile_orvexis/core/helpers/uuid_helper.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_history_item.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_overview.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_payment_adjustment_input.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_pending_employee.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_payment_preview.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_payment_preview_item.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_policy_summary.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_run_summary.dart';

class PayrollLocalDataSource {
  const PayrollLocalDataSource(this._database);

  final AppDatabase _database;

  Future<PayrollOverview> getOverview({required String organizationId}) async {
    final activeEmployeeRows = await _database
        .customSelect(
          '''
      SELECT
        ou.id_org_user AS org_user_id,
        u.name AS user_name,
        u.first_surname AS user_first_surname,
        u.second_last_name AS user_second_last_name
      FROM org_users ou
      INNER JOIN users u ON u.id_user = ou.user_id
      WHERE ou.organization_id = ?
        AND u.global_status_id = ?
      ORDER BY u.name ASC, u.first_surname ASC
      ''',
          variables: [
            Variable.withString(organizationId),
            Variable.withString(GlobalStatusDefaults.activeId),
          ],
          readsFrom: {_database.orgUsers, _database.users},
        )
        .get();

    final activeContractsRows = await _database
        .customSelect(
          '''
      SELECT
        ec.id_contract AS contract_id,
        ec.org_user_id AS org_user_id,
        ec.base_salary AS base_salary,
        pp.id_policy AS policy_id,
        pp.name AS policy_name,
        pp.pay_frequency AS pay_frequency,
        pp.currency AS currency,
        pp.is_default AS is_default
      FROM employee_contracts ec
      INNER JOIN payroll_policies pp ON pp.id_policy = ec.policy_id
      WHERE ec.organization_id = ?
        AND ec.global_status_id = ?
      ORDER BY ec.updated_at DESC, ec.created_at DESC
      ''',
          variables: [
            Variable.withString(organizationId),
            Variable.withString(GlobalStatusDefaults.activeId),
          ],
          readsFrom: {_database.employeeContracts, _database.payrollPolicies},
        )
        .get();

    final policiesRows = await _database
        .customSelect(
          '''
      SELECT
        pp.id_policy AS policy_id,
        pp.name AS policy_name,
        pp.pay_frequency AS pay_frequency,
        pp.currency AS currency,
        pp.is_default AS is_default,
        COUNT(ec.id_contract) AS assigned_employees_count,
        COALESCE(SUM(ec.base_salary), 0) AS total_base_salary
      FROM payroll_policies pp
      LEFT JOIN employee_contracts ec
        ON ec.policy_id = pp.id_policy
       AND ec.organization_id = pp.organization_id
       AND ec.global_status_id = ?
      WHERE pp.organization_id = ?
      GROUP BY
        pp.id_policy,
        pp.name,
        pp.pay_frequency,
        pp.currency,
        pp.is_default
      ORDER BY pp.is_default DESC, pp.name ASC
      ''',
          variables: [
            Variable.withString(GlobalStatusDefaults.activeId),
            Variable.withString(organizationId),
          ],
          readsFrom: {_database.payrollPolicies, _database.employeeContracts},
        )
        .get();

    final recentRunsRows = await _database
        .customSelect(
          '''
      SELECT
        pr.id_run AS run_id,
        pp.name AS policy_name,
        pp.pay_frequency AS pay_frequency,
        s.name AS status_name,
        CAST(pe.period_start AS TEXT) AS period_start,
        CAST(pe.period_end AS TEXT) AS period_end,
        CAST(COALESCE(pr.paid_at, pr.approved_at, pr.updated_at, pr.created_at) AS TEXT) AS event_at
      FROM payroll_runs pr
      INNER JOIN payroll_periods pe ON pe.id_period = pr.period_id
      INNER JOIN payroll_policies pp ON pp.id_policy = pe.policy_id
      INNER JOIN statuses s ON s.id_status = pr.status_id
      WHERE pr.organization_id = ?
      ORDER BY pr.created_at DESC
      LIMIT 6
      ''',
          variables: [Variable.withString(organizationId)],
          readsFrom: {
            _database.payrollRuns,
            _database.payrollPeriods,
            _database.payrollPolicies,
            _database.statuses,
          },
        )
        .get();

    final contractByOrgUserId = <String, _ContractSnapshot>{};

    for (final row in activeContractsRows) {
      final orgUserId = row.read<String>('org_user_id');
      contractByOrgUserId.putIfAbsent(
        orgUserId,
        () => _ContractSnapshot(
          orgUserId: orgUserId,
          baseSalary: row.read<double?>('base_salary') ?? 0,
          policyId: row.read<String>('policy_id'),
          policyName: row.read<String>('policy_name'),
          payFrequency: row.read<String>('pay_frequency'),
          currency: row.read<String?>('currency') ?? 'MXN',
          isDefault: row.read<bool>('is_default'),
        ),
      );
    }

    var weeklyEmployeesCount = 0;
    var biweeklyEmployeesCount = 0;
    var estimatedWeeklyTotal = 0.0;
    var estimatedBiweeklyTotal = 0.0;

    for (final contract in contractByOrgUserId.values) {
      if (_isBiweekly(contract.payFrequency)) {
        biweeklyEmployeesCount++;
        estimatedBiweeklyTotal += contract.baseSalary;
      } else {
        weeklyEmployeesCount++;
        estimatedWeeklyTotal += contract.baseSalary;
      }
    }

    final pendingEmployees = activeEmployeeRows
        .where(
          (row) =>
              !contractByOrgUserId.containsKey(row.read<String>('org_user_id')),
        )
        .map((row) {
          final fullName = _composeDisplayNameFromParts(
            row.read<String>('user_name'),
            row.read<String?>('user_first_surname'),
            row.read<String?>('user_second_last_name'),
          );
          return PayrollPendingEmployee(
            orgUserId: row.read<String>('org_user_id'),
            name: fullName,
            initials: _buildInitialsFromName(fullName),
          );
        })
        .toList(growable: false);

    final policies = policiesRows
        .map(
          (row) => PayrollPolicySummary(
            id: row.read<String>('policy_id'),
            name: row.read<String>('policy_name'),
            payFrequency: row.read<String>('pay_frequency'),
            currency: row.read<String?>('currency') ?? 'MXN',
            isDefault: row.read<bool>('is_default'),
            assignedEmployeesCount:
                row.read<int?>('assigned_employees_count') ?? 0,
            totalBaseSalary: row.read<double?>('total_base_salary') ?? 0,
          ),
        )
        .toList(growable: false);

    final recentRuns = recentRunsRows
        .map(
          (row) => PayrollRunSummary(
            id: row.read<String>('run_id'),
            policyName: row.read<String>('policy_name'),
            payFrequency: row.read<String>('pay_frequency'),
            statusLabel: row.read<String>('status_name'),
            periodLabel: _buildPeriodLabel(
              _tryParseDate(row.read<String?>('period_start')),
              _tryParseDate(row.read<String?>('period_end')),
            ),
            eventLabel: _relativeDateLabel(
              _tryParseDate(row.read<String?>('event_at')),
            ),
          ),
        )
        .toList(growable: false);

    return PayrollOverview(
      activeEmployeesCount: activeEmployeeRows.length,
      configuredEmployeesCount: contractByOrgUserId.length,
      pendingEmployeesCount: pendingEmployees.length,
      activePoliciesCount: policies.length,
      weeklyEmployeesCount: weeklyEmployeesCount,
      biweeklyEmployeesCount: biweeklyEmployeesCount,
      estimatedWeeklyTotal: estimatedWeeklyTotal,
      estimatedBiweeklyTotal: estimatedBiweeklyTotal,
      policies: policies,
      recentRuns: recentRuns,
      pendingEmployees: pendingEmployees,
    );
  }

  Future<PayrollPaymentPreview> getPaymentPreview({
    required String organizationId,
    required String payFrequency,
  }) async {
    final normalizedFrequency = _normalizePayFrequency(payFrequency);
    final period = _resolveCurrentPeriod(normalizedFrequency);
    final contracts = await _getContractsForFrequency(
      organizationId: organizationId,
      payFrequency: normalizedFrequency,
    );

    final totalAmount = contracts.fold<double>(
      0,
      (sum, item) => sum + item.baseSalary,
    );

    return PayrollPaymentPreview(
      payFrequency: normalizedFrequency,
      frequencyLabel: _frequencyLabel(normalizedFrequency),
      periodStart: period.start,
      periodEnd: period.end,
      periodLabel: _buildPeriodLabel(period.start, period.end),
      payDateLabel: _formatDate(period.end),
      employeesCount: contracts.length,
      totalAmount: totalAmount,
      items: contracts,
    );
  }

  Future<void> processPayment({
    required String organizationId,
    required String payFrequency,
    required List<PayrollPaymentAdjustmentInput> adjustments,
  }) async {
    final normalizedFrequency = _normalizePayFrequency(payFrequency);
    final preview = await getPaymentPreview(
      organizationId: organizationId,
      payFrequency: normalizedFrequency,
    );

    if (preview.items.isEmpty) {
      throw Exception(
        'No hay empleados activos con sueldo configurado para esta nomina.',
      );
    }

    final adjustmentByContractId = {
      for (final item in adjustments) item.contractId: item,
    };

    final paidPeriodStatusId = await _resolveStatusId(
      organizationId: organizationId,
      entity: 'payroll_period',
      code: 'paid',
      name: 'Pagado',
      sortOrder: 3,
      isTerminal: true,
    );
    final paidRunStatusId = await _resolveStatusId(
      organizationId: organizationId,
      entity: 'payroll_run',
      code: 'paid',
      name: 'Pagado',
      sortOrder: 3,
      isTerminal: true,
    );
    final paidPayslipStatusId = await _resolveStatusId(
      organizationId: organizationId,
      entity: 'payslip',
      code: 'paid',
      name: 'Pagado',
      sortOrder: 3,
      isTerminal: true,
    );

    final itemsByPolicy = <String, List<PayrollPaymentPreviewItem>>{};
    for (final item in preview.items) {
      itemsByPolicy.putIfAbsent(item.policyId, () => []).add(item);
    }

    await _database.transaction(() async {
      for (final entry in itemsByPolicy.entries) {
        final policyId = entry.key;
        final items = entry.value;
        final alreadyPaid = await _hasPaidRunForPeriod(
          organizationId: organizationId,
          policyId: policyId,
          periodStart: preview.periodStart,
          periodEnd: preview.periodEnd,
          paidRunStatusId: paidRunStatusId,
        );

        if (alreadyPaid) {
          throw Exception(
            'La nomina ${_frequencyLabel(normalizedFrequency).toLowerCase()} ya fue pagada para el periodo ${preview.periodLabel}.',
          );
        }

        final periodId = UuidHelper.generate();
        final runId = UuidHelper.generate();
        final now = DateTime.now();

        await _database
            .into(_database.payrollPeriods)
            .insert(
              PayrollPeriodsCompanion(
                idPeriod: Value(periodId),
                organizationId: Value(organizationId),
                policyId: Value(policyId),
                periodStart: Value(preview.periodStart),
                periodEnd: Value(preview.periodEnd),
                payDate: Value(preview.periodEnd),
                statusId: Value(paidPeriodStatusId),
              ),
            );

        await _database
            .into(_database.payrollRuns)
            .insert(
              PayrollRunsCompanion(
                idRun: Value(runId),
                organizationId: Value(organizationId),
                periodId: Value(periodId),
                statusId: Value(paidRunStatusId),
                approvedAt: Value(now),
                paidAt: Value(now),
              ),
            );

        for (final item in items) {
          final adjustment = adjustmentByContractId[item.contractId];
          final grossAmount = adjustment?.grossAmount ?? item.baseSalary;
          final netAmount =
              ((adjustment?.netAmount ?? item.baseSalary).clamp(
                    0,
                    grossAmount,
                  )
                  )
                  .toDouble();
          final deductionsAmount =
              (grossAmount - netAmount).clamp(0, grossAmount).toDouble();

          await _database
              .into(_database.payslips)
              .insert(
                PayslipsCompanion(
                  idPayslip: Value(UuidHelper.generate()),
                  organizationId: Value(organizationId),
                  runId: Value(runId),
                  contractId: Value(item.contractId),
                  orgUserId: Value(item.orgUserId),
                  grossAmount: Value(grossAmount),
                  deductionsAmount: Value(deductionsAmount),
                  netAmount: Value(netAmount),
                  statusId: Value(paidPayslipStatusId),
                ),
              );
        }
      }
    });
  }

  Future<List<PayrollHistoryItem>> getPayrollHistory({
    required String organizationId,
  }) async {
    final rows = await _database
        .customSelect(
          '''
      SELECT
        pr.id_run AS run_id,
        pp.name AS policy_name,
        pp.pay_frequency AS pay_frequency,
        s.name AS status_name,
        CAST(pe.period_start AS TEXT) AS period_start,
        CAST(pe.period_end AS TEXT) AS period_end,
        CAST(COALESCE(pr.paid_at, pr.approved_at, pr.updated_at, pr.created_at) AS TEXT) AS event_at,
        COUNT(ps.id_payslip) AS employees_count,
        COALESCE(SUM(ps.net_amount), 0) AS total_net_amount
      FROM payroll_runs pr
      INNER JOIN payroll_periods pe ON pe.id_period = pr.period_id
      INNER JOIN payroll_policies pp ON pp.id_policy = pe.policy_id
      INNER JOIN statuses s ON s.id_status = pr.status_id
      LEFT JOIN payslips ps ON ps.run_id = pr.id_run
      WHERE pr.organization_id = ?
      GROUP BY
        pr.id_run,
        pp.name,
        pp.pay_frequency,
        s.name,
        pe.period_start,
        pe.period_end,
        pr.paid_at,
        pr.approved_at,
        pr.updated_at,
        pr.created_at
      ORDER BY pr.created_at DESC
      ''',
          variables: [Variable.withString(organizationId)],
          readsFrom: {
            _database.payrollRuns,
            _database.payrollPeriods,
            _database.payrollPolicies,
            _database.statuses,
            _database.payslips,
          },
        )
        .get();

    return rows
        .map(
          (row) => PayrollHistoryItem(
            runId: row.read<String>('run_id'),
            policyName: row.read<String>('policy_name'),
            payFrequency: row.read<String>('pay_frequency'),
            statusLabel: row.read<String>('status_name'),
            periodLabel: _buildPeriodLabel(
              _tryParseDate(row.read<String?>('period_start')),
              _tryParseDate(row.read<String?>('period_end')),
            ),
            eventLabel: _relativeDateLabel(
              _tryParseDate(row.read<String?>('event_at')),
            ),
            employeesCount: row.read<int?>('employees_count') ?? 0,
            totalNetAmount: row.read<double?>('total_net_amount') ?? 0,
          ),
        )
        .toList(growable: false);
  }

  bool _isBiweekly(String payFrequency) {
    final normalized = payFrequency.trim().toLowerCase();
    return normalized == 'biweekly' || normalized == 'quincenal';
  }

  String _normalizePayFrequency(String payFrequency) {
    final normalized = payFrequency.trim().toLowerCase();
    if (normalized == 'quincenal') {
      return 'biweekly';
    }
    return normalized;
  }

  Future<List<PayrollPaymentPreviewItem>> _getContractsForFrequency({
    required String organizationId,
    required String payFrequency,
  }) async {
    final rows = await _database
        .customSelect(
          '''
      SELECT
        ec.id_contract AS contract_id,
        ec.org_user_id AS org_user_id,
        ec.base_salary AS base_salary,
        ec.daily_rate AS daily_rate,
        pp.id_policy AS policy_id,
        pp.name AS policy_name,
        u.name AS user_name,
        u.first_surname AS user_first_surname,
        u.second_last_name AS user_second_last_name
      FROM employee_contracts ec
      INNER JOIN payroll_policies pp ON pp.id_policy = ec.policy_id
      INNER JOIN org_users ou ON ou.id_org_user = ec.org_user_id
      INNER JOIN users u ON u.id_user = ou.user_id
      WHERE ec.organization_id = ?
        AND ec.global_status_id = ?
        AND u.global_status_id = ?
        AND pp.pay_frequency = ?
      ORDER BY ec.updated_at DESC, ec.created_at DESC
      ''',
          variables: [
            Variable.withString(organizationId),
            Variable.withString(GlobalStatusDefaults.activeId),
            Variable.withString(GlobalStatusDefaults.activeId),
            Variable.withString(payFrequency),
          ],
          readsFrom: {
            _database.employeeContracts,
            _database.payrollPolicies,
            _database.orgUsers,
            _database.users,
          },
        )
        .get();

    final seenOrgUsers = <String>{};
    final items = <PayrollPaymentPreviewItem>[];

    for (final row in rows) {
      final orgUserId = row.read<String>('org_user_id');
      if (seenOrgUsers.contains(orgUserId)) {
        continue;
      }
      seenOrgUsers.add(orgUserId);

      final fullName = _composeDisplayNameFromParts(
        row.read<String>('user_name'),
        row.read<String?>('user_first_surname'),
        row.read<String?>('user_second_last_name'),
      );

      items.add(
        PayrollPaymentPreviewItem(
          contractId: row.read<String>('contract_id'),
          orgUserId: orgUserId,
          employeeName: fullName,
          initials: _buildInitialsFromName(fullName),
          policyId: row.read<String>('policy_id'),
          policyName: row.read<String>('policy_name'),
          baseSalary: row.read<double?>('base_salary') ?? 0,
          dailyRate: row.read<double?>('daily_rate') ?? 0,
        ),
      );
    }

    return items;
  }

  ({DateTime start, DateTime end}) _resolveCurrentPeriod(String payFrequency) {
    final now = DateTime.now();

    if (_isBiweekly(payFrequency)) {
      if (now.day <= 15) {
        return (
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month, 15),
        );
      }

      return (
        start: DateTime(now.year, now.month, 16),
        end: DateTime(now.year, now.month + 1, 0),
      );
    }

    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final end = start.add(const Duration(days: 6));
    return (start: start, end: end);
  }

  Future<bool> _hasPaidRunForPeriod({
    required String organizationId,
    required String policyId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required String paidRunStatusId,
  }) async {
    final rows = await _database
        .customSelect(
          '''
      SELECT pr.id_run AS run_id
      FROM payroll_runs pr
      INNER JOIN payroll_periods pe ON pe.id_period = pr.period_id
      WHERE pr.organization_id = ?
        AND pe.policy_id = ?
        AND pe.period_start = ?
        AND pe.period_end = ?
        AND pr.status_id = ?
      LIMIT 1
      ''',
          variables: [
            Variable.withString(organizationId),
            Variable.withString(policyId),
            Variable.withDateTime(periodStart),
            Variable.withDateTime(periodEnd),
            Variable.withString(paidRunStatusId),
          ],
          readsFrom: {_database.payrollRuns, _database.payrollPeriods},
        )
        .get();

    return rows.isNotEmpty;
  }

  Future<String> _resolveStatusId({
    required String organizationId,
    required String entity,
    required String code,
    required String name,
    required int sortOrder,
    required bool isTerminal,
  }) async {
    final existing =
        await (_database.select(_database.statuses)..where(
              (tbl) =>
                  tbl.organizationId.equals(organizationId) &
                  tbl.entity.equals(entity) &
                  tbl.code.equals(code),
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
            entity: Value(entity),
            code: Value(code),
            name: Value(name),
            sortOrder: Value(sortOrder),
            isTerminal: Value(isTerminal),
          ),
        );

    return statusId;
  }

  String _frequencyLabel(String payFrequency) {
    return _isBiweekly(payFrequency) ? 'Nomina quincenal' : 'Nomina semanal';
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

  String _buildPeriodLabel(DateTime? start, DateTime? end) {
    if (start == null && end == null) {
      return 'Periodo sin fecha';
    }
    if (start != null && end != null) {
      return '${_formatDate(start)} - ${_formatDate(end)}';
    }
    if (start != null) {
      return 'Desde ${_formatDate(start)}';
    }
    return 'Hasta ${_formatDate(end!)}';
  }

  String _relativeDateLabel(DateTime? date) {
    if (date == null) {
      return 'Sin fecha';
    }

    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Hoy';
    }
    if (difference == -1) {
      return 'Ayer';
    }
    if (difference == 1) {
      return 'Manana';
    }
    if (difference < 0) {
      return 'Hace ${difference.abs()} dias';
    }
    return 'En $difference dias';
  }
}

class _ContractSnapshot {
  const _ContractSnapshot({
    required this.orgUserId,
    required this.baseSalary,
    required this.policyId,
    required this.policyName,
    required this.payFrequency,
    required this.currency,
    required this.isDefault,
  });

  final String orgUserId;
  final double baseSalary;
  final String policyId;
  final String policyName;
  final String payFrequency;
  final String currency;
  final bool isDefault;
}
