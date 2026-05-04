import 'package:flutter/material.dart';

class EmployeesEmptyState extends StatelessWidget {
  const EmployeesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Text(
        'No se encontraron empleados con ese criterio.',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
