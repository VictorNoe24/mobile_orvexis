import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/payroll/domain/usecases/get_payroll_overview_usecase.dart';
import 'package:mobile_orvexis/feature/payroll/presentation/providers/payroll_controller.dart';
import 'package:mobile_orvexis/feature/payroll/presentation/widgets/payroll_screen/payroll_tab.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({
    super.key,
    required this.getCurrentSessionUseCase,
    required this.getPayrollOverviewUseCase,
  });

  final GetCurrentSessionUseCase getCurrentSessionUseCase;
  final GetPayrollOverviewUseCase getPayrollOverviewUseCase;

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  late final PayrollController _controller = PayrollController(
    widget.getCurrentSessionUseCase,
    widget.getPayrollOverviewUseCase,
  );

  @override
  void initState() {
    super.initState();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PayrollTab(
      controller: _controller,
      onPayWeekly: () => _handlePayFrequency(context, 'weekly'),
      onPayBiweekly: () => _handlePayFrequency(context, 'biweekly'),
      onViewHistory: () => _handleViewHistory(context),
    );
  }

  Future<void> _handlePayFrequency(
    BuildContext context,
    String payFrequency,
  ) async {
    final didProcess = await context.push<bool>('/payroll/pay/$payFrequency');
    if (!mounted || didProcess != true) {
      return;
    }

    await _controller.refresh();
  }

  Future<void> _handleViewHistory(BuildContext context) async {
    await context.push('/payroll/history');
  }
}
