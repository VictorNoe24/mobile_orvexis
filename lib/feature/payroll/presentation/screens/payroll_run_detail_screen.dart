import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_report_data.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_report_item.dart';
import 'package:mobile_orvexis/feature/payroll/presentation/providers/payroll_run_detail_controller.dart';

class PayrollRunDetailScreen extends StatefulWidget {
  const PayrollRunDetailScreen({
    super.key,
    required this.runId,
    required this.controller,
  });

  final String runId;
  final PayrollRunDetailController controller;

  @override
  State<PayrollRunDetailScreen> createState() => _PayrollRunDetailScreenState();
}

class _PayrollRunDetailScreenState extends State<PayrollRunDetailScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.load(widget.runId);
  }

  @override
  void didUpdateWidget(covariant PayrollRunDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.runId != widget.runId) {
      widget.controller.load(widget.runId);
    }
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final report = widget.controller.report;
        return Scaffold(
          appBar: AppBar(title: const Text('Detalle de nómina')),
          body: widget.controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : widget.controller.errorMessage != null || report == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      widget.controller.errorMessage ??
                          'No se pudo cargar el detalle de la nómina.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      _PayrollRunSummary(report: report),
                      const SizedBox(height: 24),
                      Text(
                        'Personal pagado (${report.employeesCount})',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 14),
                      ...report.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _EmployeePaymentCard(item: item),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _PayrollRunSummary extends StatelessWidget {
  const _PayrollRunSummary({required this.report});

  final PayrollReportData report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1841A5), Color(0xFF2E6EF7)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            report.payFrequency == 'biweekly'
                ? 'Nómina quincenal'
                : 'Nómina semanal',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            report.periodLabel,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _currency(report.totalNetAmount),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total pagado · ${report.employeesCount} empleados',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: 'Sueldo base',
                  value: _currency(report.totalGrossAmount),
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  label: 'Descuentos',
                  value: _currency(report.totalDeductionsAmount),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _EmployeePaymentCard extends StatelessWidget {
  const _EmployeePaymentCard({required this.item});

  final PayrollReportItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.employeeName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          _PaymentLine(
            label: 'Sueldo base',
            value: _currency(item.grossAmount),
          ),
          const SizedBox(height: 8),
          _PaymentLine(
            label: 'Descuentos',
            value: '-${_currency(item.deductionsAmount)}',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _PaymentLine(
            label: 'Pago final',
            value: _currency(item.netAmount),
            isEmphasized: true,
          ),
        ],
      ),
    );
  }
}

class _PaymentLine extends StatelessWidget {
  const _PaymentLine({
    required this.label,
    required this.value,
    this.isEmphasized = false,
  });

  final String label;
  final String value;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isEmphasized ? colors.onSurface : colors.onSurfaceVariant,
              fontWeight: isEmphasized ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: isEmphasized ? colors.primary : colors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

String _currency(double amount) {
  final fixed = amount.isFinite ? amount.toStringAsFixed(0) : '0';
  final chars = fixed.split('').reversed.toList();
  final buffer = StringBuffer();
  for (var index = 0; index < chars.length; index++) {
    if (index > 0 && index % 3 == 0) buffer.write(',');
    buffer.write(chars[index]);
  }
  return '\$${buffer.toString().split('').reversed.join()}';
}
