import 'package:flutter/material.dart';
import 'package:mobile_orvexis/config/theme/theme_controller.dart';
import 'package:mobile_orvexis/core/database/app_database.dart';
import 'package:mobile_orvexis/core/database/queries/global_statuses_queries.dart';

class HomeScreen extends StatelessWidget {
  final ThemeController themeController;
  final AppDatabase database;

  const HomeScreen({
    super.key,
    required this.themeController,
    required this.database,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final globalStatusesQueries = GlobalStatusesQueries(database);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: StreamBuilder<List<GlobalStatuse>>(
        stream: globalStatusesQueries.watchAllOrdered(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error al cargar global statuses: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final statuses = snapshot.data ?? [];
          final duplicateCodes = globalStatusesQueries.duplicateCodeCount(
            statuses,
          );

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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Validacion de seeders',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Total de registros: ${statuses.length}'),
                      Text('Codigos duplicados detectados: $duplicateCodes'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (statuses.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No hay global statuses registrados.'),
                  ),
                )
              else
                ...statuses.map(
                  (status) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(status.sortOrder?.toString() ?? '-'),
                      ),
                      title: Text(status.name),
                      subtitle: Text(
                        'code: ${status.code}\n'
                        'entity: ${status.entity}\n'
                        'id: ${status.idGlobalStatus}\n'
                        'category: ${status.category ?? 'Sin categoria'}\n'
                        'terminal: ${status.isTerminal ? 'Si' : 'No'}\n'
                        'activo: ${status.isActive ? 'Si' : 'No'}',
                      ),
                      isThreeLine: true,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
