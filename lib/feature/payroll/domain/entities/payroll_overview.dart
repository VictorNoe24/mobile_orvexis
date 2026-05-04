import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_pending_employee.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_policy_summary.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_run_summary.dart';

class PayrollOverview {
  const PayrollOverview({
    required this.activeEmployeesCount,
    required this.configuredEmployeesCount,
    required this.pendingEmployeesCount,
    required this.activePoliciesCount,
    required this.weeklyEmployeesCount,
    required this.biweeklyEmployeesCount,
    required this.estimatedWeeklyTotal,
    required this.estimatedBiweeklyTotal,
    required this.policies,
    required this.recentRuns,
    required this.pendingEmployees,
  });

  final int activeEmployeesCount;
  final int configuredEmployeesCount;
  final int pendingEmployeesCount;
  final int activePoliciesCount;
  final int weeklyEmployeesCount;
  final int biweeklyEmployeesCount;
  final double estimatedWeeklyTotal;
  final double estimatedBiweeklyTotal;
  final List<PayrollPolicySummary> policies;
  final List<PayrollRunSummary> recentRuns;
  final List<PayrollPendingEmployee> pendingEmployees;
}
