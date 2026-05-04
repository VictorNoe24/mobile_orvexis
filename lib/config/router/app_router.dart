import 'package:go_router/go_router.dart';
import 'package:mobile_orvexis/config/theme/theme_controller.dart';
import 'package:mobile_orvexis/core/database/app_database.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/has_active_session_usecase.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/login_usecase.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/logout_usecase.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/register_admin_with_organization_usecase.dart';
import 'package:mobile_orvexis/feature/employees/domain/usecases/create_employee_usecase.dart';
import 'package:mobile_orvexis/feature/employees/domain/usecases/get_employee_by_id_usecase.dart';
import 'package:mobile_orvexis/feature/employees/domain/usecases/get_employee_role_names_usecase.dart';
import 'package:mobile_orvexis/feature/employees/domain/usecases/update_employee_usecase.dart';
import 'package:mobile_orvexis/feature/auth/infrastructure/datasources/auth_credentials_local_datasource.dart';
import 'package:mobile_orvexis/feature/auth/infrastructure/datasources/auth_local_datasource.dart';
import 'package:mobile_orvexis/feature/auth/infrastructure/datasources/auth_session_local_datasource.dart';
import 'package:mobile_orvexis/feature/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:mobile_orvexis/feature/auth/presentation/providers/login_controller.dart';
import 'package:mobile_orvexis/feature/auth/presentation/providers/register_organization_controller.dart';
import 'package:mobile_orvexis/feature/employees/infrastructure/datasources/employees_local_datasource.dart';
import 'package:mobile_orvexis/feature/employees/infrastructure/repositories/employees_repository_impl.dart';
import 'package:mobile_orvexis/feature/employees/presentation/providers/create_employee_controller.dart';
import 'package:mobile_orvexis/feature/employees/presentation/providers/edit_employee_controller.dart';
import 'package:mobile_orvexis/feature/employees/presentation/screens/create_employee_screen.dart';
import 'package:mobile_orvexis/feature/employees/presentation/screens/edit_employee_screen.dart';
import 'package:mobile_orvexis/feature/roles/domain/usecases/create_role_usecase.dart';
import 'package:mobile_orvexis/feature/roles/domain/usecases/get_role_by_id_usecase.dart';
import 'package:mobile_orvexis/feature/roles/domain/usecases/get_roles_usecase.dart';
import 'package:mobile_orvexis/feature/roles/domain/usecases/update_role_usecase.dart';
import 'package:mobile_orvexis/feature/roles/infrastructure/datasources/roles_local_datasource.dart';
import 'package:mobile_orvexis/feature/roles/infrastructure/repositories/roles_repository_impl.dart';
import 'package:mobile_orvexis/feature/roles/presentation/providers/create_role_controller.dart';
import 'package:mobile_orvexis/feature/roles/presentation/providers/edit_role_controller.dart';
import 'package:mobile_orvexis/feature/roles/presentation/providers/roles_controller.dart';
import 'package:mobile_orvexis/feature/roles/presentation/screens/create_role_screen.dart';
import 'package:mobile_orvexis/feature/roles/presentation/screens/edit_role_screen.dart';
import 'package:mobile_orvexis/feature/roles/presentation/screens/roles_screen.dart';
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
  final employeesLocalDataSource = EmployeesLocalDataSource(database);
  final employeesRepository = EmployeesRepositoryImpl(employeesLocalDataSource);
  final createEmployeeUseCase = CreateEmployeeUseCase(employeesRepository);
  final getEmployeeByIdUseCase = GetEmployeeByIdUseCase(employeesRepository);
  final getEmployeeRoleNamesUseCase = GetEmployeeRoleNamesUseCase(
    employeesRepository,
  );
  final updateEmployeeUseCase = UpdateEmployeeUseCase(employeesRepository);
  final rolesLocalDataSource = RolesLocalDataSource(database);
  final rolesRepository = RolesRepositoryImpl(rolesLocalDataSource);
  final createRoleUseCase = CreateRoleUseCase(rolesRepository);
  final getRolesUseCase = GetRolesUseCase(rolesRepository);
  final getRoleByIdUseCase = GetRoleByIdUseCase(rolesRepository);
  final updateRoleUseCase = UpdateRoleUseCase(rolesRepository);

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
              employeesLocalDataSource: employeesLocalDataSource,
            ),
      ),
      GoRoute(
        path: '/employees/create',
        builder: (context, state) => CreateEmployeeScreen(
          controller: CreateEmployeeController(
            getCurrentSessionUseCase,
            createEmployeeUseCase,
            getEmployeeRoleNamesUseCase,
          ),
        ),
      ),
      GoRoute(
        path: '/employees/:employeeId/edit',
        builder: (context, state) => EditEmployeeScreen(
          employeeId: state.pathParameters['employeeId']!,
          controller: EditEmployeeController(
            getCurrentSessionUseCase,
            getEmployeeByIdUseCase,
            getEmployeeRoleNamesUseCase,
            updateEmployeeUseCase,
          ),
        ),
      ),
      GoRoute(
        path: '/roles',
        builder: (context, state) => RolesScreen(
          controller: RolesController(
            getCurrentSessionUseCase,
            getRolesUseCase,
          ),
        ),
      ),
      GoRoute(
        path: '/roles/create',
        builder: (context, state) => CreateRoleScreen(
          controller: CreateRoleController(
            getCurrentSessionUseCase,
            createRoleUseCase,
          ),
        ),
      ),
      GoRoute(
        path: '/roles/:roleId/edit',
        builder: (context, state) => EditRoleScreen(
          roleId: state.pathParameters['roleId']!,
          controller: EditRoleController(
            getCurrentSessionUseCase,
            getRoleByIdUseCase,
            updateRoleUseCase,
          ),
        ),
      ),
    ],
  );
}
