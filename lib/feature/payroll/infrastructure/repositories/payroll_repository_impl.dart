import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_history_item.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_overview.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_payment_adjustment_input.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_payment_preview.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_report_data.dart';
import 'package:mobile_orvexis/feature/payroll/domain/repositories/payroll_repository.dart';
import 'package:mobile_orvexis/feature/payroll/infrastructure/datasources/payroll_local_datasource.dart';

class PayrollRepositoryImpl implements PayrollRepository {
  const PayrollRepositoryImpl(this._localDataSource);

  final PayrollLocalDataSource _localDataSource;

  @override
  Future<PayrollOverview> getOverview({required String organizationId}) {
    return _localDataSource.getOverview(organizationId: organizationId);
  }

  @override
  Future<PayrollPaymentPreview> getPaymentPreview({
    required String organizationId,
    required String payFrequency,
  }) {
    return _localDataSource.getPaymentPreview(
      organizationId: organizationId,
      payFrequency: payFrequency,
    );
  }

  @override
  Future<void> processPayment({
    required String organizationId,
    required String payFrequency,
    required List<PayrollPaymentAdjustmentInput> adjustments,
  }) {
    return _localDataSource.processPayment(
      organizationId: organizationId,
      payFrequency: payFrequency,
      adjustments: adjustments,
    );
  }

  @override
  Future<List<PayrollHistoryItem>> getPayrollHistory({
    required String organizationId,
  }) {
    return _localDataSource.getPayrollHistory(organizationId: organizationId);
  }

  @override
  Future<PayrollReportData> getPayrollReport({
    required String organizationId,
    required String runId,
  }) {
    return _localDataSource.getPayrollReport(
      organizationId: organizationId,
      runId: runId,
    );
  }
}
