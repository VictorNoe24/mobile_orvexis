import 'package:flutter/material.dart';
import 'package:mobile_orvexis/config/theme/theme_controller.dart';

class HomeSettingsTab extends StatelessWidget {
  const HomeSettingsTab({
    super.key,
    required this.themeController,
    required this.onManageRoles,
    required this.onLogout,
  });

  final ThemeController themeController;
  final VoidCallback onManageRoles;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.dark_mode, color: colors.primary),
                const SizedBox(width: 12),
                const Expanded(child: Text('Modo oscuro')),
                Switch(
                  value: themeController.themeMode == ThemeMode.dark,
                  onChanged: themeController.toggleTheme,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: onManageRoles,
          icon: const Icon(Icons.badge_rounded),
          label: const Text('Gestionar roles'),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Cerrar sesion'),
        ),
      ],
    );
  }
}
