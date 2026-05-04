import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/auth/domain/entities/auth_session.dart';

class HomeDashboardTab extends StatelessWidget {
  const HomeDashboardTab({super.key, required this.session});

  final AuthSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _HomeHeaderCard(session: session),
          const SizedBox(height: 24),
          Text(
            'Resumen de rendimiento',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: _MetricSummaryCard(
                  icon: Icons.groups_rounded,
                  title: 'Total de empleados',
                  value: '125',
                  badgeText: '+5%',
                  badgeColor: Color(0xFFDFF7EA),
                  badgeTextColor: Color(0xFF149954),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MetricSummaryCard(
                  icon: Icons.work_outline_rounded,
                  title: 'Proyectos',
                  value: '8',
                  badgeText: 'Activos',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _PayrollStatusCard(),
          const SizedBox(height: 24),
          Text(
            'Acciones rapidas',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _QuickActionItem(
                  icon: Icons.fact_check_outlined,
                  label: 'Registrar\nAsistencia',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _QuickActionItem(
                  icon: Icons.person_add_alt_1_rounded,
                  label: 'Agregar\nEmpleado',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _QuickActionItem(
                  icon: Icons.apartment_rounded,
                  label: 'Crear\nProyecto',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _QuickActionItem(
                  icon: Icons.payments_outlined,
                  label: 'Ejecutar\nNomina',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Alertas y actividades',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          const _AlertActivityCard(
            title: 'Discrepancia de asistencia',
            description:
                'Se detectaron 3 nuevos incidentes de asistencia en el proyecto "Torres Elysium".',
          ),
          const SizedBox(height: 12),
          const _AlertActivityCard(
            title: 'Nuevo proyecto aprobado',
            description:
                'La fase 1 de "Renovacion del puente del puerto" ha sido aprobada para la asignacion.',
          ),
          const SizedBox(height: 12),
          const _AlertActivityCard(
            title: 'Recordatorio de cierre de nomina',
            description: 'El periodo de nomina actual finaliza en 2 dias.',
          ),
        ],
      ),
    );
  }
}

class _HomeHeaderCard extends StatelessWidget {
  const _HomeHeaderCard({required this.session});

  final AuthSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final userName = _displayNameFromEmail(session.email);

    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Icon(Icons.business_rounded, color: colors.primary, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Skyline Builders Group',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFFFFD6C8),
          child: Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF5B2D1F),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricSummaryCard extends StatelessWidget {
  const _MetricSummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.badgeText,
    this.badgeColor,
    this.badgeTextColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final String badgeText;
  final Color? badgeColor;
  final Color? badgeTextColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: colors.onSurface),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeColor ?? colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Text(
                  badgeText,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: badgeTextColor ?? colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayrollStatusCard extends StatelessWidget {
  const _PayrollStatusCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E6EEB),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332E6EEB),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'ESTADO ACTUAL DE LA NOMINA',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.payments_outlined,
                color: Colors.white,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Periodo quincenal #14',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '70%',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Finaliza en 2 dias (31 de octubre)',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFD9E6FF),
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 0.7,
              minHeight: 4,
              backgroundColor: Color(0x80FFFFFF),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7E56DA)),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Center(child: Icon(icon, color: colors.onSurface, size: 22)),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class _AlertActivityCard extends StatelessWidget {
  const _AlertActivityCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.auto_awesome_mosaic_rounded,
              color: colors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.35,
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

String _displayNameFromEmail(String email) {
  final localPart = email.split('@').first.trim();
  if (localPart.isEmpty) return 'ConstructPay Pro';

  final normalized = localPart.replaceAll(RegExp(r'[._-]+'), ' ');
  return normalized
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
