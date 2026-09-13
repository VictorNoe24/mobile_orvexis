import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_payment_preview_item.dart';

class PayrollPaymentPreview {
  const PayrollPaymentPreview({
    required this.payFrequency,
    required this.frequencyLabel,
    required this.periodStart,
    required this.periodEnd,
    required this.periodLabel,
    required this.payDateLabel,
    this.projectName,
    required this.employeesCount,
    required this.totalAmount,
    required this.items,
  });

  final String payFrequency;
  final String frequencyLabel;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String periodLabel;
  final String payDateLabel;
  final String? projectName;
  final int employeesCount;
  final double totalAmount;
  final List<PayrollPaymentPreviewItem> items;
}
