class PayrollRunSummary {
  const PayrollRunSummary({
    required this.id,
    required this.policyName,
    required this.payFrequency,
    required this.statusLabel,
    required this.periodLabel,
    required this.eventLabel,
  });

  final String id;
  final String policyName;
  final String payFrequency;
  final String statusLabel;
  final String periodLabel;
  final String eventLabel;
}
