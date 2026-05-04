import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_overview.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_history_item.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_payment_adjustment_input.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_payment_preview.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_report_data.dart';

abstract class PayrollRepository {
  Future<PayrollOverview> getOverview({required String organizationId});

  Future<PayrollPaymentPreview> getPaymentPreview({
    required String organizationId,
    required String payFrequency,
  });

  Future<void> processPayment({
    required String organizationId,
    required String payFrequency,
    required List<PayrollPaymentAdjustmentInput> adjustments,
  });

  Future<List<PayrollHistoryItem>> getPayrollHistory({
    required String organizationId,
  });

  Future<PayrollReportData> getPayrollReport({
    required String organizationId,
    required String runId,
  });
}
