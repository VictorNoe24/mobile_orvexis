import 'package:mobile_orvexis/feature/auth/domain/entities/auth_session.dart';
import 'package:mobile_orvexis/feature/auth/domain/entities/login_input.dart';
import 'package:mobile_orvexis/feature/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<AuthSession> call(LoginInput input) {
    return _authRepository.login(input);
  }
}
