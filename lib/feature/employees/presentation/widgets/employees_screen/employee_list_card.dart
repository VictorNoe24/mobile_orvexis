import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/employee.dart';

class EmployeeListCard extends StatelessWidget {
  const EmployeeListCard({
    super.key,
    required this.employee,
    required this.onTap,
  });

  final Employee employee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colors.primary.withValues(alpha: 0.18),
                child: Text(
                  employee.initials,
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee.role,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ingreso: ${employee.startDate}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: employee.isActive
                          ? const Color(0xFFDDF8E6)
                          : const Color(0xFFF3E1E1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: employee.isActive
                            ? const Color(0xFFABDDB9)
                            : const Color(0xFFE4B8B8),
                      ),
                    ),
                    child: Text(
                      employee.isActive ? 'Activos' : 'Inactivos',
                      style: TextStyle(
                        color: employee.isActive
                            ? const Color(0xFF317B4C)
                            : const Color(0xFF9A4A4A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 30,
                    color: colors.onSurface,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
