import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_orvexis/feature/backups/domain/entities/backup_restore_plan.dart';
import 'package:mobile_orvexis/feature/backups/presentation/providers/backup_controller.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key, required this.controller});

  final BackupController controller;

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _createBackup() async {
    final destination = await widget.controller.createAndExport();
    if (!mounted) return;
    final error = widget.controller.errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ??
              (destination == null
                  ? 'El respaldo está listo. Guárdalo desde el selector de archivos.'
                  : 'Respaldo guardado correctamente.'),
        ),
      ),
    );
  }

  Future<void> _selectAndRestore() async {
    final plan = await widget.controller.selectForRestore();
    if (!mounted) return;
    if (plan == null) {
      final error = widget.controller.errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
      return;
    }

    final confirmed = await _confirmRestore(plan);
    if (confirmed != true || !mounted) return;

    final success = await widget.controller.restore(plan);
    if (!mounted || success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.controller.errorMessage ?? 'No se pudo restaurar el respaldo.',
        ),
      ),
    );
  }

  Future<bool?> _confirmRestore(BackupRestorePlan plan) {
    final date = DateFormat(
      "d 'de' MMMM, y · h:mm a",
      'es_MX',
    ).format(plan.createdAt);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('¿Restaurar este respaldo?'),
        content: Text(
          'Se reemplazarán los datos actuales por la copia del $date. '
          'La aplicación se reiniciará al terminar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isWorking = widget.controller.isWorking;

    return Scaffold(
      appBar: AppBar(title: const Text('Respaldo y restauración')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.backup_rounded, color: colors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Crear respaldo',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Guarda una copia completa de la base de datos, imágenes de proyectos y reportes de nómina.',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isWorking ? null : _createBackup,
                      icon: const Icon(Icons.save_alt_rounded),
                      label: const Text('Crear y guardar respaldo'),
                    ),
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
                  Row(
                    children: [
                      Icon(Icons.restore_rounded, color: colors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Restaurar respaldo',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Selecciona un archivo .zip creado por Orvexis. Esta acción sustituye la información actual.',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isWorking ? null : _selectAndRestore,
                      icon: const Icon(Icons.folder_open_rounded),
                      label: const Text('Seleccionar respaldo'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Importante: la sesión y contraseñas no se incluyen en el archivo de respaldo.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          if (isWorking) ...[
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}
