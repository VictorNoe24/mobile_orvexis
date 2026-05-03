import 'package:mobile_orvexis/feature/auth/domain/repositories/auth_repository.dart';

class HasActiveSessionUseCase {
  const HasActiveSessionUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<bool> call() {
    return _authRepository.hasActiveSession();
  }
}
