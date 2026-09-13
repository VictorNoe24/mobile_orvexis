import 'package:flutter/foundation.dart';
import 'package:mobile_orvexis/feature/backups/domain/entities/backup_file.dart';
import 'package:mobile_orvexis/feature/backups/domain/entities/backup_restore_plan.dart';
import 'package:mobile_orvexis/feature/backups/domain/usecases/create_backup_usecase.dart';
import 'package:mobile_orvexis/feature/backups/domain/usecases/export_backup_usecase.dart';
import 'package:mobile_orvexis/feature/backups/domain/usecases/select_backup_for_restore_usecase.dart';

class BackupController extends ChangeNotifier {
  BackupController({
    required CreateBackupUseCase createBackupUseCase,
    required ExportBackupUseCase exportBackupUseCase,
    required SelectBackupForRestoreUseCase selectBackupForRestoreUseCase,
    required Future<void> Function(BackupRestorePlan plan) onRestoreCompleted,
  }) : _createBackupUseCase = createBackupUseCase,
       _exportBackupUseCase = exportBackupUseCase,
       _selectBackupForRestoreUseCase = selectBackupForRestoreUseCase,
       _onRestoreCompleted = onRestoreCompleted;

  final CreateBackupUseCase _createBackupUseCase;
  final ExportBackupUseCase _exportBackupUseCase;
  final SelectBackupForRestoreUseCase _selectBackupForRestoreUseCase;
  final Future<void> Function(BackupRestorePlan plan) _onRestoreCompleted;

  bool isWorking = false;
  String? errorMessage;
  BackupFile? latestBackup;

  Future<String?> createAndExport() async {
    isWorking = true;
    errorMessage = null;
    notifyListeners();
    try {
      latestBackup = await _createBackupUseCase();
      return await _exportBackupUseCase(latestBackup!);
    } catch (error) {
      errorMessage = _messageFor(error);
      return null;
    } finally {
      isWorking = false;
      notifyListeners();
    }
  }

  Future<BackupRestorePlan?> selectForRestore() async {
    isWorking = true;
    errorMessage = null;
    notifyListeners();
    try {
      return await _selectBackupForRestoreUseCase();
    } catch (error) {
      errorMessage = _messageFor(error);
      return null;
    } finally {
      isWorking = false;
      notifyListeners();
    }
  }

  Future<bool> restore(BackupRestorePlan plan) async {
    isWorking = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _onRestoreCompleted(plan);
      return true;
    } catch (error) {
      errorMessage = _messageFor(error);
      isWorking = false;
      notifyListeners();
      return false;
    }
  }

  String _messageFor(Object error) {
    if (error is FormatException) return error.message.toString();
    return 'No se pudo completar la operación. Intenta nuevamente.';
  }
}
