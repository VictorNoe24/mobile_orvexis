import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/roles/domain/entities/role_item.dart';

class RoleListTile extends StatelessWidget {
  const RoleListTile({
    super.key,
    required this.role,
    required this.onTap,
  });

  final RoleItem role;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: colors.primary.withValues(alpha: 0.14),
          child: Icon(
            role.isSystem ? Icons.admin_panel_settings_rounded : Icons.badge_rounded,
            color: colors.primary,
          ),
        ),
        title: Text(
          role.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text('Codigo: ${role.code}'),
        trailing: role.isSystem
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Sistema',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
