class EmployeeCompensationFormData {
  const EmployeeCompensationFormData({
    required this.payFrequency,
    required this.baseSalary,
    required this.dailyRate,
    required this.workDaysPerPeriod,
    required this.contractType,
    this.contractId,
  });

  final String payFrequency;
  final double? baseSalary;
  final double? dailyRate;
  final int workDaysPerPeriod;
  final String contractType;
  final String? contractId;
}
