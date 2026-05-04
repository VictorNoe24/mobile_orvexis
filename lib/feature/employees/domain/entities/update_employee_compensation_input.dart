class UpdateEmployeeCompensationInput {
  const UpdateEmployeeCompensationInput({
    required this.payFrequency,
    required this.baseSalary,
    required this.workDaysPerPeriod,
  });

  final String payFrequency;
  final double baseSalary;
  final int workDaysPerPeriod;
}
