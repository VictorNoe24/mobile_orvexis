class PayrollPaymentPreviewItem {
  const PayrollPaymentPreviewItem({
    required this.contractId,
    required this.orgUserId,
    required this.employeeName,
    required this.initials,
    required this.policyId,
    required this.policyName,
    required this.baseSalary,
    required this.dailyRate,
  });

  final String contractId;
  final String orgUserId;
  final String employeeName;
  final String initials;
  final String policyId;
  final String policyName;
  final double baseSalary;
  final double dailyRate;
}
