import 'package:mobile_orvexis/feature/backups/domain/entities/backup_restore_plan.dart';
import 'package:mobile_orvexis/feature/backups/domain/repositories/backup_repository.dart';

class SelectBackupForRestoreUseCase {
  const SelectBackupForRestoreUseCase(this._repository);

  final BackupRepository _repository;

  Future<BackupRestorePlan?> call() => _repository.selectBackupForRestore();
}
