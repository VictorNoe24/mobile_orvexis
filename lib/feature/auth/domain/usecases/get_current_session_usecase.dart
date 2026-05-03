import 'package:mobile_orvexis/feature/auth/domain/entities/auth_session.dart';
import 'package:mobile_orvexis/feature/auth/domain/repositories/auth_repository.dart';

class GetCurrentSessionUseCase {
  const GetCurrentSessionUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<AuthSession?> call() {
    return _authRepository.getCurrentSession();
  }
}
