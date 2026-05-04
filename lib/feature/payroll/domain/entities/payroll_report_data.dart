import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_report_item.dart';

class PayrollReportData {
  const PayrollReportData({
    required this.runId,
    required this.organizationName,
    required this.policyName,
    required this.payFrequency,
    required this.statusLabel,
    required this.periodLabel,
    required this.payDateLabel,
    required this.generatedAtLabel,
    required this.employeesCount,
    required this.totalGrossAmount,
    required this.totalDeductionsAmount,
    required this.totalNetAmount,
    required this.items,
  });

  final String runId;
  final String organizationName;
  final String policyName;
  final String payFrequency;
  final String statusLabel;
  final String periodLabel;
  final String payDateLabel;
  final String generatedAtLabel;
  final int employeesCount;
  final double totalGrossAmount;
  final double totalDeductionsAmount;
  final double totalNetAmount;
  final List<PayrollReportItem> items;
}
