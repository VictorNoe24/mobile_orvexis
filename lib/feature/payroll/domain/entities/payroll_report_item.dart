class PayrollReportItem {
  const PayrollReportItem({
    required this.employeeName,
    required this.grossAmount,
    required this.deductionsAmount,
    required this.netAmount,
  });

  final String employeeName;
  final double grossAmount;
  final double deductionsAmount;
  final double netAmount;
}
