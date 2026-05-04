class PayrollHistoryItem {
  const PayrollHistoryItem({
    required this.runId,
    required this.policyName,
    required this.payFrequency,
    required this.statusLabel,
    required this.periodLabel,
    required this.eventLabel,
    required this.employeesCount,
    required this.totalNetAmount,
  });

  final String runId;
  final String policyName;
  final String payFrequency;
  final String statusLabel;
  final String periodLabel;
  final String eventLabel;
  final int employeesCount;
  final double totalNetAmount;
}
