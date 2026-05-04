import 'package:mobile_orvexis/core/helpers/password_hasher.dart';
import 'package:mobile_orvexis/feature/auth/domain/entities/auth_session.dart';
import 'package:mobile_orvexis/feature/auth/domain/entities/login_input.dart';
import 'package:mobile_orvexis/feature/auth/domain/entities/register_admin_organization_input.dart';
import 'package:mobile_orvexis/feature/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_orvexis/feature/auth/infrastructure/datasources/auth_credentials_local_datasource.dart';
import 'package:mobile_orvexis/feature/auth/infrastructure/datasources/auth_local_datasource.dart';
import 'package:mobile_orvexis/feature/auth/infrastructure/datasources/auth_session_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(
    this._localDataSource,
    this._credentialsLocalDataSource,
    this._sessionLocalDataSource,
  );

  final AuthLocalDataSource _localDataSource;
  final AuthCredentialsLocalDataSource _credentialsLocalDataSource;
  final AuthSessionLocalDataSource _sessionLocalDataSource;

  @override
  Future<void> registerAdminWithOrganization(RegisterAdminOrganizationInput input) async {
    await _localDataSource.registerAdminWithOrganization(input);

    final normalizedEmail = input.adminUser.email.trim().toLowerCase();
    final user = await _localDataSource.getUserByEmail(normalizedEmail);
    if (user == null) {
      throw Exception('No fue posible encontrar el usuario recien creado.');
    }
    final relations = await _localDataSource.getOrganizationsByUser(user.idUser);
    if (relations.isEmpty) {
      throw Exception('No fue posible resolver la organizacion del usuario.');
    }
    final organizationId = relations.first.organization.idOrganization;

    await _credentialsLocalDataSource.saveCredentials(
      userId: user.idUser,
      email: normalizedEmail,
      passwordHash: PasswordHasher.hash(input.adminUser.password),
    );

    await _sessionLocalDataSource.saveSession(
      AuthSession(
        userId: user.idUser,
        email: normalizedEmail,
        organizationId: organizationId,
      ),
    );
  }

  @override
  Future<AuthSession> login(LoginInput input) async {
    final normalizedEmail = input.email.trim().toLowerCase();
    final user = await _localDataSource.getUserByEmail(normalizedEmail);

    if (user == null) {
      throw Exception('No existe una cuenta con ese correo.');
    }

    final credentialRecord = await _credentialsLocalDataSource.findByEmail(
      normalizedEmail,
    );

    if (credentialRecord == null) {
      throw Exception('No se encontraron credenciales para este usuario.');
    }

    final passwordHash = credentialRecord['passwordHash'] as String?;
    if (passwordHash == null ||
        !PasswordHasher.matches(
          rawValue: input.password,
          hashedValue: passwordHash,
        )) {
      throw Exception('La contrasena es incorrecta.');
    }

    final relations = await _localDataSource.getOrganizationsByUser(user.idUser);
    if (relations.isEmpty) {
      throw Exception('El usuario no pertenece a ninguna organizacion.');
    }

    final session = AuthSession(
      userId: user.idUser,
      email: normalizedEmail,
      organizationId: relations.first.organization.idOrganization,
    );
    await _sessionLocalDataSource.saveSession(session);
    return session;
  }

  @override
  Future<bool> hasActiveSession() {
    return _sessionLocalDataSource.hasSession();
  }

  @override
  Future<AuthSession?> getCurrentSession() {
    return _sessionLocalDataSource.getSession();
  }

  @override
  Future<void> logout() {
    return _sessionLocalDataSource.clearSession();
  }
}
