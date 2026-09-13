import 'package:mobile_orvexis/feature/backups/domain/entities/backup_file.dart';
import 'package:mobile_orvexis/feature/backups/domain/repositories/backup_repository.dart';

class CreateBackupUseCase {
  const CreateBackupUseCase(this._repository);

  final BackupRepository _repository;

  Future<BackupFile> call() => _repository.createBackup();
}
