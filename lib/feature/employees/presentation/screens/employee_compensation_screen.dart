import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/update_employee_compensation_input.dart';
import 'package:mobile_orvexis/feature/employees/presentation/providers/employee_compensation_controller.dart';

class EmployeeCompensationScreen extends StatefulWidget {
  const EmployeeCompensationScreen({
    super.key,
    required this.employeeId,
    required this.controller,
  });

  final String employeeId;
  final EmployeeCompensationController controller;

  @override
  State<EmployeeCompensationScreen> createState() =>
      _EmployeeCompensationScreenState();
}

class _EmployeeCompensationScreenState
    extends State<EmployeeCompensationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _salaryController = TextEditingController();
  final _workDaysController = TextEditingController();
  final _absentDaysController = TextEditingController(text: '0');
  bool _didSeedForm = false;
  String _selectedFrequency = 'weekly';

  @override
  void initState() {
    super.initState();
    widget.controller.initialize(widget.employeeId);
  }

  @override
  void didUpdateWidget(covariant EmployeeCompensationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.employeeId != widget.employeeId) {
      _didSeedForm = false;
      widget.controller.initialize(widget.employeeId);
    }
  }

  @override
  void dispose() {
    widget.controller.dispose();
    _salaryController.dispose();
    _workDaysController.dispose();
    _absentDaysController.dispose();
    super.dispose();
  }

  void _seedFormIfNeeded() {
    final data = widget.controller.formData;
    if (_didSeedForm || data == null) return;

    _selectedFrequency = data.payFrequency;
    _salaryController.text = data.baseSalary?.toStringAsFixed(2) ?? '';
    _workDaysController.text = data.workDaysPerPeriod.toString();
    _didSeedForm = true;
  }

  double get _salaryValue =>
      double.tryParse(_salaryController.text.trim().replaceAll(',', '')) ?? 0;

  int get _workDaysValue => int.tryParse(_workDaysController.text.trim()) ?? 0;

  int get _absentDaysValue =>
      int.tryParse(_absentDaysController.text.trim()) ?? 0;

  double get _dailyRatePreview {
    if (_salaryValue <= 0 || _workDaysValue <= 0) {
      return 0;
    }
    return _salaryValue / _workDaysValue;
  }

  double get _netPayPreview {
    final dailyRate = _dailyRatePreview;
    final absentDays = _absentDaysValue.clamp(
      0,
      _workDaysValue > 0 ? _workDaysValue : 0,
    );
    final net = _salaryValue - (dailyRate * absentDays);
    return net < 0 ? 0 : net;
  }

  Future<void> _handleSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    try {
      await widget.controller.save(
        employeeId: widget.employeeId,
        input: UpdateEmployeeCompensationInput(
          payFrequency: _selectedFrequency,
          baseSalary: _salaryValue,
          workDaysPerPeriod: _workDaysValue,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sueldo guardado correctamente.')),
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

  String? _salaryValidator(String? value) {
    final parsed = double.tryParse(value?.trim().replaceAll(',', '') ?? '');
    if (parsed == null || parsed <= 0) {
      return 'Ingresa un sueldo valido.';
    }
    return null;
  }

  String? _daysValidator(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed <= 0) {
      return 'Ingresa dias validos.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        if (widget.controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (widget.controller.errorMessage != null ||
            widget.controller.formData == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Configurar sueldo')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  widget.controller.errorMessage ??
                      'No se pudo cargar la compensacion.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        _seedFormIfNeeded();
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final periodLabel = _selectedFrequency == 'biweekly'
            ? 'quincena'
            : 'semana';

        return Scaffold(
          appBar: AppBar(title: const Text('Configurar sueldo')),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  Text(
                    'Sueldo fijo del empleado',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Define si el pago fijo se maneja por semana o por quincena y calcula cuanto se pagaria si faltan dias.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedFrequency,
                    items: const [
                      DropdownMenuItem(value: 'weekly', child: Text('Semanal')),
                      DropdownMenuItem(
                        value: 'biweekly',
                        child: Text('Quincenal'),
                      ),
                    ],
                    onChanged: widget.controller.isSaving
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedFrequency = value;
                              if (_workDaysController.text.trim().isEmpty ||
                                  _workDaysValue <= 0) {
                                _workDaysController.text = value == 'biweekly'
                                    ? '12'
                                    : '6';
                              }
                            });
                          },
                    decoration: const InputDecoration(
                      labelText: 'Forma de pago',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _salaryController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _salaryValidator,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Sueldo fijo por $periodLabel',
                      hintText: 'Ej. 4200.00',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _workDaysController,
                    keyboardType: TextInputType.number,
                    validator: _daysValidator,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Dias laborables por $periodLabel',
                      hintText: _selectedFrequency == 'biweekly' ? '12' : '6',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Simulador por faltas',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Usa esto para ver cuanto se pagaria en el periodo si el empleado faltara algunos dias.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _absentDaysController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'Dias faltados en el periodo',
                              hintText: '0',
                            ),
                          ),
                          const SizedBox(height: 16),
                          _CompensationMetricRow(
                            label: 'Pago fijo del periodo',
                            value: _formatCurrency(_salaryValue),
                          ),
                          const SizedBox(height: 10),
                          _CompensationMetricRow(
                            label: 'Descuento por dia',
                            value: _formatCurrency(_dailyRatePreview),
                          ),
                          const SizedBox(height: 10),
                          _CompensationMetricRow(
                            label: 'Pago estimado',
                            value: _formatCurrency(_netPayPreview),
                            emphasize: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: widget.controller.isSaving
                        ? null
                        : _handleSubmit,
                    child: Text(
                      widget.controller.isSaving
                          ? 'Guardando...'
                          : 'Guardar sueldo',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatCurrency(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }
}

class _CompensationMetricRow extends StatelessWidget {
  const _CompensationMetricRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: emphasize ? colors.primary : colors.onSurface,
          ),
        ),
      ],
    );
  }
}
