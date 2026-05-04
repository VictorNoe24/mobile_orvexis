import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_overview.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_pending_employee.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_policy_summary.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_run_summary.dart';
import 'package:mobile_orvexis/feature/payroll/presentation/providers/payroll_controller.dart';

class PayrollTab extends StatelessWidget {
  const PayrollTab({
    super.key,
    required this.controller,
    required this.onPayWeekly,
    required this.onPayBiweekly,
    required this.onViewHistory,
  });

  final PayrollController controller;
  final VoidCallback onPayWeekly;
  final VoidCallback onPayBiweekly;
  final VoidCallback onViewHistory;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage != null || controller.overview == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                controller.errorMessage ??
                    'No se pudo cargar el modulo de nomina.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final overview = controller.overview!;
        final theme = Theme.of(context);

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _PayrollHeroCard(overview: overview),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onPayWeekly,
                        icon: const Icon(Icons.payments_rounded),
                        label: const Text('Pagar semanal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: onPayBiweekly,
                        icon: const Icon(Icons.calendar_month_rounded),
                        label: const Text('Pagar quincenal'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Resumen operativo',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.badge_rounded,
                        title: 'Con sueldo',
                        value:
                            '${overview.configuredEmployeesCount}/${overview.activeEmployeesCount}',
                        tone: _MetricTone.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.pending_actions_rounded,
                        title: 'Pendientes',
                        value: '${overview.pendingEmployeesCount}',
                        tone: overview.pendingEmployeesCount == 0
                            ? _MetricTone.success
                            : _MetricTone.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.rule_folder_rounded,
                        title: 'Politicas',
                        value: '${overview.activePoliciesCount}',
                        tone: _MetricTone.neutral,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.receipt_long_rounded,
                        title: 'Corridas',
                        value: '${overview.recentRuns.length}',
                        tone: _MetricTone.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Cortes configurados',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                _PayFrequencyCard(
                  title: 'Nomina semanal',
                  subtitle:
                      '${overview.weeklyEmployeesCount} empleados relacionados',
                  amount: overview.estimatedWeeklyTotal,
                  accent: const Color(0xFF2E6EF7),
                ),
                const SizedBox(height: 12),
                _PayFrequencyCard(
                  title: 'Nomina quincenal',
                  subtitle:
                      '${overview.biweeklyEmployeesCount} empleados relacionados',
                  amount: overview.estimatedBiweeklyTotal,
                  accent: const Color(0xFF0F9D8A),
                ),
                const SizedBox(height: 24),
                Text(
                  'Politicas de pago',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                if (overview.policies.isEmpty)
                  const _EmptySectionCard(
                    icon: Icons.rule_folder_outlined,
                    title: 'Aun no hay politicas configuradas.',
                    description:
                        'Configura sueldos desde empleados para comenzar a construir la operacion de nomina.',
                  )
                else
                  ...overview.policies.map(
                    (policy) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PolicySummaryCard(policy: policy),
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  'Pendientes de configuracion',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                if (overview.pendingEmployees.isEmpty)
                  const _EmptySectionCard(
                    icon: Icons.verified_user_rounded,
                    title: 'Todo el personal activo ya tiene sueldo.',
                    description:
                        'La configuracion base de nomina esta completa para los empleados activos.',
                  )
                else
                  ...overview.pendingEmployees
                      .take(5)
                      .map(
                        (employee) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PendingEmployeeTile(employee: employee),
                        ),
                      ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Corridas recientes',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onViewHistory,
                      child: const Text('Ver historial'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (overview.recentRuns.isEmpty)
                  const _EmptySectionCard(
                    icon: Icons.playlist_add_check_circle_outlined,
                    title: 'Todavia no hay corridas de nomina.',
                    description:
                        'Cuando registres periodos y ejecuciones de nomina apareceran aqui.',
                  )
                else
                  ...overview.recentRuns.map(
                    (run) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PayrollRunCard(run: run),
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

class _PayrollHeroCard extends StatelessWidget {
  const _PayrollHeroCard({required this.overview});

  final PayrollOverview overview;

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
          colors: [Color(0xFF204EB8), Color(0xFF2E6EF7), Color(0xFF5B9CFF)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332E6EF7),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${overview.pendingEmployeesCount} por configurar',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Centro de nomina',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Supervisa cortes semanales y quincenales, empleados listos para pago y configuraciones pendientes.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  label: 'Semanal estimado',
                  value: _currency(overview.estimatedWeeklyTotal),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeroStat(
                  label: 'Quincenal estimado',
                  value: _currency(overview.estimatedBiweeklyTotal),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.90),
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

enum _MetricTone { primary, success, warning, neutral }

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String title;
  final String value;
  final _MetricTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = Theme.of(context).colorScheme;
    final accent = switch (tone) {
      _MetricTone.primary => colors.primary,
      _MetricTone.success => const Color(0xFF149954),
      _MetricTone.warning => const Color(0xFFB46B00),
      _MetricTone.neutral => colors.onSurface,
    };
    final background = switch (tone) {
      _MetricTone.primary => colors.primary.withValues(alpha: 0.08),
      _MetricTone.success => const Color(0xFFE7F7ED),
      _MetricTone.warning => const Color(0xFFFFF3DA),
      _MetricTone.neutral => colors.surfaceContainerHighest,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayFrequencyCard extends StatelessWidget {
  const _PayFrequencyCard({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final double amount;
  final Color accent;

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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.event_repeat_rounded, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _currency(amount),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicySummaryCard extends StatelessWidget {
  const _PolicySummaryCard({required this.policy});

  final PayrollPolicySummary policy;

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
                  policy.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (policy.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Predeterminada',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _frequencyLabel(policy.payFrequency),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PolicyMetric(
                  label: 'Empleados',
                  value: '${policy.assignedEmployeesCount}',
                ),
              ),
              Expanded(
                child: _PolicyMetric(
                  label: 'Monto configurado',
                  value: _currency(policy.totalBaseSalary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PolicyMetric extends StatelessWidget {
  const _PolicyMetric({required this.label, required this.value});

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

class _PendingEmployeeTile extends StatelessWidget {
  const _PendingEmployeeTile({required this.employee});

  final PayrollPendingEmployee employee;

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
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFFFF3DA),
            child: Text(
              employee.initials,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFFB46B00),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Falta configurar sueldo y frecuencia de pago.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _PayrollRunCard extends StatelessWidget {
  const _PayrollRunCard({required this.run});

  final PayrollRunSummary run;

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
                  run.policyName,
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
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  run.statusLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _frequencyLabel(run.payFrequency),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            run.periodLabel,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            run.eventLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySectionCard extends StatelessWidget {
  const _EmptySectionCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: colors.primary),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
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

String _frequencyLabel(String frequency) {
  final normalized = frequency.trim().toLowerCase();
  switch (normalized) {
    case 'biweekly':
      return 'Frecuencia quincenal';
    case 'weekly':
      return 'Frecuencia semanal';
    default:
      return frequency;
  }
}
