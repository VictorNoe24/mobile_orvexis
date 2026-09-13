import 'package:mobile_orvexis/feature/backups/domain/entities/backup_restore_plan.dart';
import 'package:mobile_orvexis/feature/backups/domain/repositories/backup_repository.dart';

class RestoreBackupUseCase {
  const RestoreBackupUseCase(this._repository);

  final BackupRepository _repository;

  Future<void> call(BackupRestorePlan plan) => _repository.restore(plan);
}
