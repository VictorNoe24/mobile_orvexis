import 'package:go_router/go_router.dart';
import 'package:mobile_orvexis/config/theme/theme_controller.dart';
import 'package:mobile_orvexis/core/database/app_database.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/has_active_session_usecase.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/login_usecase.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/logout_usecase.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/register_admin_with_organization_usecase.dart';
import 'package:mobile_orvexis/feature/auth/infrastructure/datasources/auth_credentials_local_datasource.dart';
import 'package:mobile_orvexis/feature/auth/infrastructure/datasources/auth_local_datasource.dart';
import 'package:mobile_orvexis/feature/auth/infrastructure/datasources/auth_session_local_datasource.dart';
import 'package:mobile_orvexis/feature/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:mobile_orvexis/feature/auth/presentation/providers/login_controller.dart';
import 'package:mobile_orvexis/feature/auth/presentation/providers/register_organization_controller.dart';
import '../../feature/auth/presentation/screens/start_screen.dart';
import '../../feature/auth/presentation/screens/login_screen.dart';
import '../../feature/auth/presentation/screens/register_organization_screen.dart';
import '../../feature/home/presentation/screens/home_screen.dart';
import '../../feature/splash/presentation/screens/splash_screen.dart';

GoRouter appRouter({
  required ThemeController themeController,
  required AppDatabase database,
}) {
  final authLocalDataSource = AuthLocalDataSource(database);
  final authCredentialsLocalDataSource = AuthCredentialsLocalDataSource();
  final authSessionLocalDataSource = AuthSessionLocalDataSource();
  final authRepository = AuthRepositoryImpl(
    authLocalDataSource,
    authCredentialsLocalDataSource,
    authSessionLocalDataSource,
  );
  final hasActiveSessionUseCase = HasActiveSessionUseCase(authRepository);
  final getCurrentSessionUseCase = GetCurrentSessionUseCase(authRepository);
  final loginUseCase = LoginUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);
  final registerAdminWithOrganizationUseCase =
      RegisterAdminWithOrganizationUseCase(authRepository);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashScreen(
          database: database,
          hasActiveSessionUseCase: hasActiveSessionUseCase,
        ),
      ),
      GoRoute(path: '/start', builder: (context, state) => const StartScreen()),
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            LoginScreen(controller: LoginController(loginUseCase)),
      ),
      GoRoute(
        path: '/register-organization',
        builder: (context, state) =>
            RegisterOrganizationScreen(
              controller: RegisterOrganizationController(
                registerAdminWithOrganizationUseCase,
              ),
            ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) =>
            HomeScreen(
              themeController: themeController,
              getCurrentSessionUseCase: getCurrentSessionUseCase,
              logoutUseCase: logoutUseCase,
            ),
      ),
    ],
  );
}
