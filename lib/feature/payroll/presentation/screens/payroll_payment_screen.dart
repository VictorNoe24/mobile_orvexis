import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_payment_adjustment_input.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_payment_preview.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_payment_preview_item.dart';
import 'package:mobile_orvexis/feature/payroll/presentation/providers/payroll_payment_controller.dart';

class PayrollPaymentScreen extends StatefulWidget {
  const PayrollPaymentScreen({
    super.key,
    required this.payFrequency,
    required this.controller,
  });

  final String payFrequency;
  final PayrollPaymentController controller;

  @override
  State<PayrollPaymentScreen> createState() => _PayrollPaymentScreenState();
}

class _PayrollPaymentScreenState extends State<PayrollPaymentScreen> {
  final Map<String, double> _absentDayOverrides = <String, double>{};
  final Map<String, TextEditingController> _manualAmountControllers =
      <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    widget.controller.initialize(widget.payFrequency);
  }

  @override
  void didUpdateWidget(covariant PayrollPaymentScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.payFrequency != widget.payFrequency) {
      _disposeAmountControllers();
      widget.controller.initialize(widget.payFrequency);
    }
  }

  @override
  void dispose() {
    _disposeAmountControllers();
    widget.controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    try {
      final preview = widget.controller.preview;
      if (preview == null) {
        return;
      }

      final adjustments = preview.items.map(_buildAdjustment).toList();

      await widget.controller.submitWithAdjustments(
        payFrequency: widget.payFrequency,
        adjustments: adjustments,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomina pagada y guardada en historial.')),
      );
      context.pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  void _hydrateControllers(PayrollPaymentPreview preview) {
    for (final item in preview.items) {
      _absentDayOverrides.putIfAbsent(item.contractId, () => 0);
      _manualAmountControllers.putIfAbsent(
        item.contractId,
        () => TextEditingController(text: item.baseSalary.toStringAsFixed(2)),
      );
    }
  }

  void _disposeAmountControllers() {
    for (final controller in _manualAmountControllers.values) {
      controller.dispose();
    }
    _manualAmountControllers.clear();
    _absentDayOverrides.clear();
  }

  PayrollPaymentAdjustmentInput _buildAdjustment(
    PayrollPaymentPreviewItem item,
  ) {
    final controller = _manualAmountControllers[item.contractId];
    final absentDays = _absentDayOverrides[item.contractId] ?? 0;
    final automaticNet =
        ((item.baseSalary - (item.dailyRate * absentDays)).clamp(
              0,
              item.baseSalary,
            )
            )
            .toDouble();
    final manualValue = double.tryParse(
      (controller?.text ?? '').replaceAll(',', '').trim(),
    );
    final netAmount = ((manualValue ?? automaticNet).clamp(
      0,
      item.baseSalary,
    )
    )
        .toDouble();

    return PayrollPaymentAdjustmentInput(
      contractId: item.contractId,
      orgUserId: item.orgUserId,
      grossAmount: item.baseSalary,
      netAmount: netAmount,
    );
  }

  double _effectiveNetAmount(PayrollPaymentPreviewItem item) {
    return _buildAdjustment(item).netAmount;
  }

  double _previewTotal(PayrollPaymentPreview preview) {
    return preview.items.fold<double>(
      0,
      (sum, item) => sum + _effectiveNetAmount(item),
    );
  }

  void _incrementAbsentDays(PayrollPaymentPreviewItem item, double delta) {
    final next = (((_absentDayOverrides[item.contractId] ?? 0) + delta).clamp(
      0,
      31,
    )
    )
        .toDouble();
    _absentDayOverrides[item.contractId] = next;
    final automaticNet =
        ((item.baseSalary - (item.dailyRate * next)).clamp(
              0,
              item.baseSalary,
            )
            )
            .toDouble();
    _manualAmountControllers[item.contractId]?.text = automaticNet
        .toStringAsFixed(2);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final preview = widget.controller.preview;

        return Scaffold(
          appBar: AppBar(title: const Text('Pagar nomina')),
          body: widget.controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : widget.controller.errorMessage != null || preview == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      widget.controller.errorMessage ??
                          'No se pudo preparar esta nomina.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          children: [
                            ...(() {
                              _hydrateControllers(preview);
                              return const <Widget>[];
                            })(),
                            _PaymentHero(preview: preview),
                            const SizedBox(height: 20),
                            _PeriodCard(preview: preview),
                            const SizedBox(height: 16),
                            _EditableSummaryCard(
                              preview: preview,
                              adjustedTotal: _previewTotal(preview),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Empleados incluidos',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 14),
                            if (preview.items.isEmpty)
                              const _EmptyPaymentEmployeesCard()
                            else
                              ...preview.items.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _EditablePaymentEmployeeTile(
                                    item: item,
                                    absentDays:
                                        _absentDayOverrides[item.contractId] ??
                                        0,
                                    amountController:
                                        _manualAmountControllers[item
                                            .contractId]!,
                                    onAbsentChanged: (delta) =>
                                        _incrementAbsentDays(item, delta),
                                    netAmount: _effectiveNetAmount(item),
                                    onAmountChanged: () => setState(() {}),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: ElevatedButton.icon(
                          onPressed: widget.controller.isSaving
                              ? null
                              : _handleSubmit,
                          icon: const Icon(Icons.payments_rounded),
                          label: Text(
                            widget.controller.isSaving
                                ? 'Procesando pago...'
                                : 'Confirmar y pagar',
                          ),
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

class _PaymentHero extends StatelessWidget {
  const _PaymentHero({required this.preview});

  final PayrollPaymentPreview preview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
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
            preview.frequencyLabel,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Se generaran recibos y corrida pagada para este periodo.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: 'Personal',
                  value: '${preview.employeesCount}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeroMetric(
                  label: 'Total',
                  value: _currency(preview.totalAmount),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({required this.preview});

  final PayrollPaymentPreview preview;

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
          Text(
            'Periodo a pagar',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          _PeriodMetric(label: 'Rango', value: preview.periodLabel),
          const SizedBox(height: 10),
          _PeriodMetric(label: 'Fecha de pago', value: preview.payDateLabel),
        ],
      ),
    );
  }
}

class _PeriodMetric extends StatelessWidget {
  const _PeriodMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _EditableSummaryCard extends StatelessWidget {
  const _EditableSummaryCard({
    required this.preview,
    required this.adjustedTotal,
  });

  final PayrollPaymentPreview preview;
  final double adjustedTotal;

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
      child: Row(
        children: [
          Expanded(
            child: _PeriodMetric(
              label: 'Base definida',
              value: _currency(preview.totalAmount),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pago ajustado',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currency(adjustedTotal),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditablePaymentEmployeeTile extends StatelessWidget {
  const _EditablePaymentEmployeeTile({
    required this.item,
    required this.absentDays,
    required this.amountController,
    required this.onAbsentChanged,
    required this.netAmount,
    required this.onAmountChanged,
  });

  final PayrollPaymentPreviewItem item;
  final double absentDays;
  final TextEditingController amountController;
  final ValueChanged<double> onAbsentChanged;
  final double netAmount;
  final VoidCallback onAmountChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colors.primary.withValues(alpha: 0.12),
                child: Text(
                  item.initials,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.employeeName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.policyName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniMetric(
                  label: 'Sueldo base',
                  value: _currency(item.baseSalary),
                ),
              ),
              Expanded(
                child: _MiniMetric(
                  label: 'Por dia',
                  value: _currency(item.dailyRate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Dias no laborados',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onAbsentChanged(-0.5),
                icon: const Icon(Icons.remove_circle_outline_rounded),
              ),
              Text(
                absentDays % 1 == 0
                    ? absentDays.toStringAsFixed(0)
                    : absentDays.toStringAsFixed(1),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                onPressed: () => onAbsentChanged(0.5),
                icon: const Icon(Icons.add_circle_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => onAmountChanged(),
            decoration: const InputDecoration(
              labelText: 'Monto final a pagar',
              prefixText: '\$',
              hintText: '0.00',
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pago ajustado: ${_currency(netAmount)}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});

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
        const SizedBox(height: 6),
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

class _EmptyPaymentEmployeesCard extends StatelessWidget {
  const _EmptyPaymentEmployeesCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No hay empleados con sueldo configurado para este corte.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: colors.onSurfaceVariant),
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
