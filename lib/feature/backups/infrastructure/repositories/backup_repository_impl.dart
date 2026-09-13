import 'package:mobile_orvexis/feature/backups/domain/entities/backup_file.dart';
import 'package:mobile_orvexis/feature/backups/domain/entities/backup_restore_plan.dart';
import 'package:mobile_orvexis/feature/backups/domain/repositories/backup_repository.dart';
import 'package:mobile_orvexis/feature/backups/infrastructure/datasources/backup_local_datasource.dart';

class BackupRepositoryImpl implements BackupRepository {
  const BackupRepositoryImpl(this._dataSource);

  final BackupLocalDataSource _dataSource;

  @override
  Future<BackupFile> createBackup() => _dataSource.createBackup();

  @override
  Future<String?> exportBackup(BackupFile backup) =>
      _dataSource.exportBackup(backup);

  @override
  Future<BackupRestorePlan?> selectBackupForRestore() =>
      _dataSource.selectBackupForRestore();

  @override
  Future<void> restore(BackupRestorePlan plan) => _dataSource.restore(plan);
}
