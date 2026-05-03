import 'package:mobile_orvexis/feature/auth/domain/entities/auth_session.dart';
import 'package:mobile_orvexis/feature/auth/domain/entities/login_input.dart';
import 'package:mobile_orvexis/feature/auth/domain/entities/register_admin_organization_input.dart';

abstract class AuthRepository {
  Future<void> registerAdminWithOrganization(
    RegisterAdminOrganizationInput input,
  );

  Future<AuthSession> login(LoginInput input);

  Future<bool> hasActiveSession();

  Future<AuthSession?> getCurrentSession();

  Future<void> logout();
}
