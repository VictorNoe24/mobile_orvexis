import 'package:flutter/material.dart';
import 'package:mobile_orvexis/config/theme/theme_controller.dart';

class HomeScreen extends StatelessWidget {
  final ThemeController themeController;

  const HomeScreen({
    super.key,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.dark_mode, color: colors.primary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Modo oscuro'),
                    ),
                    Switch(
                      value: themeController.themeMode == ThemeMode.dark,
                      onChanged: themeController.toggleTheme,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Botón principal'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Botón secundario'),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Escribe aquí',
              ),
            ),
          ],
        ),
      ),
    );
  }
}