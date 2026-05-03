import 'package:mobile_orvexis/feature/auth/domain/entities/register_admin_organization_input.dart';
import 'package:mobile_orvexis/feature/auth/domain/repositories/auth_repository.dart';

class RegisterAdminWithOrganizationUseCase {
  const RegisterAdminWithOrganizationUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> call(RegisterAdminOrganizationInput input) {
    return _authRepository.registerAdminWithOrganization(input);
  }
}
