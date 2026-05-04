class PayrollPaymentAdjustmentInput {
  const PayrollPaymentAdjustmentInput({
    required this.contractId,
    required this.orgUserId,
    required this.grossAmount,
    required this.netAmount,
  });

  final String contractId;
  final String orgUserId;
  final double grossAmount;
  final double netAmount;
}
