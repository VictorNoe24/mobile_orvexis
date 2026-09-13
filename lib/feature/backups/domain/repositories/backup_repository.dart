import 'package:mobile_orvexis/feature/backups/domain/entities/backup_file.dart';
import 'package:mobile_orvexis/feature/backups/domain/entities/backup_restore_plan.dart';

abstract class BackupRepository {
  Future<BackupFile> createBackup();
  Future<String?> exportBackup(BackupFile backup);
  Future<BackupRestorePlan?> selectBackupForRestore();
  Future<void> restore(BackupRestorePlan plan);
}
