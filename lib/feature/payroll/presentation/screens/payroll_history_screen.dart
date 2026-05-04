import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_history_item.dart';
import 'package:mobile_orvexis/feature/payroll/presentation/providers/payroll_history_controller.dart';

class PayrollHistoryScreen extends StatefulWidget {
  const PayrollHistoryScreen({super.key, required this.controller});

  final PayrollHistoryController controller;

  @override
  State<PayrollHistoryScreen> createState() => _PayrollHistoryScreenState();
}

class _PayrollHistoryScreenState extends State<PayrollHistoryScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.initialize();
  }

  @override
  void didUpdateWidget(covariant PayrollHistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      widget.controller.initialize();
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
        return Scaffold(
          appBar: AppBar(title: const Text('Historial de nomina')),
          body: widget.controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : widget.controller.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      widget.controller.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : widget.controller.items.isEmpty
              ? const _EmptyPayrollHistoryState()
              : SafeArea(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: widget.controller.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.controller.items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PayrollHistoryCard(item: item),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}

class _PayrollHistoryCard extends StatelessWidget {
  const _PayrollHistoryCard({required this.item});

  final PayrollHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.policyName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F7ED),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.statusLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF149954),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.payFrequency == 'biweekly'
                ? 'Nomina quincenal'
                : 'Nomina semanal',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.periodLabel,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.eventLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HistoryMetric(
                  label: 'Recibos',
                  value: '${item.employeesCount}',
                ),
              ),
              Expanded(
                child: _HistoryMetric(
                  label: 'Monto pagado',
                  value: _currency(item.totalNetAmount),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryMetric extends StatelessWidget {
  const _HistoryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _EmptyPayrollHistoryState extends StatelessWidget {
  const _EmptyPayrollHistoryState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded, size: 42, color: colors.primary),
            const SizedBox(height: 12),
            Text(
              'Aun no hay pagos registrados en el historial.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

String _currency(double amount) {
  final normalized = amount.isFinite ? amount : 0;
  final fixed = normalized.toStringAsFixed(0);
  final chars = fixed.split('').reversed.toList();
  final buffer = StringBuffer();

  for (var index = 0; index < chars.length; index++) {
    if (index > 0 && index % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(chars[index]);
  }

  return '\$${buffer.toString().split('').reversed.join()}';
}
