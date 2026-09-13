import 'package:mobile_orvexis/feature/backups/domain/entities/backup_file.dart';
import 'package:mobile_orvexis/feature/backups/domain/repositories/backup_repository.dart';

class ExportBackupUseCase {
  const ExportBackupUseCase(this._repository);

  final BackupRepository _repository;

  Future<String?> call(BackupFile backup) => _repository.exportBackup(backup);
}
