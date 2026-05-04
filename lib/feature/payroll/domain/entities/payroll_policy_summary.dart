class PayrollPolicySummary {
  const PayrollPolicySummary({
    required this.id,
    required this.name,
    required this.payFrequency,
    required this.currency,
    required this.isDefault,
    required this.assignedEmployeesCount,
    required this.totalBaseSalary,
  });

  final String id;
  final String name;
  final String payFrequency;
  final String currency;
  final bool isDefault;
  final int assignedEmployeesCount;
  final double totalBaseSalary;
}
