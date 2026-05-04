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
import 'package:mobile_orvexis/feature/employees/domain/usecases/get_employee_compensation_usecase.dart';
import 'package:mobile_orvexis/feature/employees/domain/usecases/get_employee_role_names_usecase.dart';
import 'package:mobile_orvexis/feature/employees/domain/usecases/update_employee_usecase.dart';
import 'package:mobile_orvexis/feature/employees/domain/usecases/update_employee_compensation_usecase.dart';
import 'package:mobile_orvexis/feature/auth/infrastructure/datasources/auth_credentials_local_datasource.dart';
import 'package:mobile_orvexis/feature/auth/infrastructure/datasources/auth_local_datasource.dart';
import 'package:mobile_orvexis/feature/auth/infrastructure/datasources/auth_session_local_datasource.dart';
import 'package:mobile_orvexis/feature/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:mobile_orvexis/feature/auth/presentation/providers/login_controller.dart';
import 'package:mobile_orvexis/feature/auth/presentation/providers/register_organization_controller.dart';
import 'package:mobile_orvexis/feature/employees/infrastructure/datasources/employees_local_datasource.dart';
import 'package:mobile_orvexis/feature/employees/infrastructure/repositories/employees_repository_impl.dart';
import 'package:mobile_orvexis/feature/employees/presentation/providers/create_employee_controller.dart';
import 'package:mobile_orvexis/feature/employees/presentation/providers/employee_compensation_controller.dart';
import 'package:mobile_orvexis/feature/employees/presentation/providers/edit_employee_controller.dart';
import 'package:mobile_orvexis/feature/employees/presentation/screens/employee_compensation_screen.dart';
import 'package:mobile_orvexis/feature/employees/presentation/screens/create_employee_screen.dart';
import 'package:mobile_orvexis/feature/employees/presentation/screens/edit_employee_screen.dart';
import 'package:mobile_orvexis/feature/projects/domain/usecases/create_project_usecase.dart';
import 'package:mobile_orvexis/feature/projects/domain/usecases/get_assignable_project_employees_usecase.dart';
import 'package:mobile_orvexis/feature/projects/domain/usecases/get_project_assigned_employees_usecase.dart';
import 'package:mobile_orvexis/feature/projects/domain/usecases/get_project_detail_usecase.dart';
import 'package:mobile_orvexis/feature/projects/domain/usecases/get_project_form_data_usecase.dart';
import 'package:mobile_orvexis/feature/projects/domain/usecases/get_projects_usecase.dart';
import 'package:mobile_orvexis/feature/projects/domain/usecases/assign_employees_to_project_usecase.dart';
import 'package:mobile_orvexis/feature/projects/domain/usecases/remove_employee_from_project_usecase.dart';
import 'package:mobile_orvexis/feature/projects/domain/usecases/update_project_usecase.dart';
import 'package:mobile_orvexis/feature/payroll/domain/usecases/get_payroll_overview_usecase.dart';
import 'package:mobile_orvexis/feature/payroll/domain/usecases/get_payroll_history_usecase.dart';
import 'package:mobile_orvexis/feature/payroll/domain/usecases/get_payroll_payment_preview_usecase.dart';
import 'package:mobile_orvexis/feature/payroll/domain/usecases/get_payroll_report_usecase.dart';
import 'package:mobile_orvexis/feature/payroll/domain/usecases/process_payroll_payment_usecase.dart';
import 'package:mobile_orvexis/feature/payroll/infrastructure/datasources/payroll_local_datasource.dart';
import 'package:mobile_orvexis/feature/payroll/infrastructure/repositories/payroll_repository_impl.dart';
import 'package:mobile_orvexis/feature/payroll/infrastructure/services/payroll_pdf_service.dart';
import 'package:mobile_orvexis/feature/payroll/presentation/providers/payroll_history_controller.dart';
import 'package:mobile_orvexis/feature/payroll/presentation/providers/payroll_payment_controller.dart';
import 'package:mobile_orvexis/feature/payroll/presentation/screens/payroll_history_screen.dart';
import 'package:mobile_orvexis/feature/payroll/presentation/screens/payroll_payment_screen.dart';
import 'package:mobile_orvexis/feature/projects/infrastructure/datasources/projects_local_datasource.dart';
import 'package:mobile_orvexis/feature/projects/infrastructure/repositories/projects_repository_impl.dart';
import 'package:mobile_orvexis/feature/projects/presentation/providers/assign_project_employees_controller.dart';
import 'package:mobile_orvexis/feature/projects/presentation/providers/create_project_controller.dart';
import 'package:mobile_orvexis/feature/projects/presentation/providers/edit_project_controller.dart';
import 'package:mobile_orvexis/feature/projects/presentation/providers/project_detail_controller.dart';
import 'package:mobile_orvexis/feature/projects/presentation/screens/assign_project_employees_screen.dart';
import 'package:mobile_orvexis/feature/projects/presentation/screens/create_project_screen.dart';
import 'package:mobile_orvexis/feature/projects/presentation/screens/edit_project_screen.dart';
import 'package:mobile_orvexis/feature/projects/presentation/screens/project_activities_screen.dart';
import 'package:mobile_orvexis/feature/projects/presentation/screens/project_assigned_employees_screen.dart';
import 'package:mobile_orvexis/feature/projects/presentation/screens/project_detail_screen.dart';
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
  final getEmployeeCompensationUseCase = GetEmployeeCompensationUseCase(
    employeesRepository,
  );
  final updateEmployeeUseCase = UpdateEmployeeUseCase(employeesRepository);
  final updateEmployeeCompensationUseCase = UpdateEmployeeCompensationUseCase(
    employeesRepository,
  );
  final payrollLocalDataSource = PayrollLocalDataSource(database);
  final payrollRepository = PayrollRepositoryImpl(payrollLocalDataSource);
  final getPayrollOverviewUseCase = GetPayrollOverviewUseCase(
    payrollRepository,
  );
  final getPayrollPaymentPreviewUseCase = GetPayrollPaymentPreviewUseCase(
    payrollRepository,
  );
  final getPayrollReportUseCase = GetPayrollReportUseCase(payrollRepository);
  final processPayrollPaymentUseCase = ProcessPayrollPaymentUseCase(
    payrollRepository,
  );
  final getPayrollHistoryUseCase = GetPayrollHistoryUseCase(payrollRepository);
  const payrollPdfService = PayrollPdfService();
  final projectsLocalDataSource = ProjectsLocalDataSource(database);
  final projectsRepository = ProjectsRepositoryImpl(projectsLocalDataSource);
  final getProjectsUseCase = GetProjectsUseCase(projectsRepository);
  final createProjectUseCase = CreateProjectUseCase(projectsRepository);
  final getProjectDetailUseCase = GetProjectDetailUseCase(projectsRepository);
  final getProjectAssignedEmployeesUseCase = GetProjectAssignedEmployeesUseCase(
    projectsRepository,
  );
  final getProjectFormDataUseCase = GetProjectFormDataUseCase(
    projectsRepository,
  );
  final getAssignableProjectEmployeesUseCase =
      GetAssignableProjectEmployeesUseCase(projectsRepository);
  final assignEmployeesToProjectUseCase = AssignEmployeesToProjectUseCase(
    projectsRepository,
  );
  final removeEmployeeFromProjectUseCase = RemoveEmployeeFromProjectUseCase(
    projectsRepository,
  );
  final updateProjectUseCase = UpdateProjectUseCase(projectsRepository);
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
        builder: (context, state) => RegisterOrganizationScreen(
          controller: RegisterOrganizationController(
            registerAdminWithOrganizationUseCase,
          ),
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => HomeScreen(
          themeController: themeController,
          getCurrentSessionUseCase: getCurrentSessionUseCase,
          logoutUseCase: logoutUseCase,
          employeesLocalDataSource: employeesLocalDataSource,
          getProjectsUseCase: getProjectsUseCase,
          getPayrollOverviewUseCase: getPayrollOverviewUseCase,
        ),
      ),
      GoRoute(
        path: '/projects/create',
        builder: (context, state) => CreateProjectScreen(
          controller: CreateProjectController(
            getCurrentSessionUseCase,
            createProjectUseCase,
          ),
        ),
      ),
      GoRoute(
        path: '/projects/:projectId',
        builder: (context, state) => ProjectDetailScreen(
          projectId: state.pathParameters['projectId']!,
          controller: ProjectDetailController(
            getCurrentSessionUseCase,
            getProjectDetailUseCase,
            getProjectAssignedEmployeesUseCase,
            removeEmployeeFromProjectUseCase,
          ),
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/employees',
        builder: (context, state) => ProjectAssignedEmployeesScreen(
          projectId: state.pathParameters['projectId']!,
          controller: ProjectDetailController(
            getCurrentSessionUseCase,
            getProjectDetailUseCase,
            getProjectAssignedEmployeesUseCase,
            removeEmployeeFromProjectUseCase,
          ),
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/activities',
        builder: (context, state) => ProjectActivitiesScreen(
          projectId: state.pathParameters['projectId']!,
          controller: ProjectDetailController(
            getCurrentSessionUseCase,
            getProjectDetailUseCase,
            getProjectAssignedEmployeesUseCase,
            removeEmployeeFromProjectUseCase,
          ),
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/edit',
        builder: (context, state) => EditProjectScreen(
          projectId: state.pathParameters['projectId']!,
          controller: EditProjectController(
            getCurrentSessionUseCase,
            getProjectFormDataUseCase,
            updateProjectUseCase,
          ),
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/assign-employees',
        builder: (context, state) => AssignProjectEmployeesScreen(
          projectId: state.pathParameters['projectId']!,
          controller: AssignProjectEmployeesController(
            getCurrentSessionUseCase,
            getAssignableProjectEmployeesUseCase,
            assignEmployeesToProjectUseCase,
          ),
        ),
      ),
      GoRoute(
        path: '/payroll/pay/:frequency',
        builder: (context, state) => PayrollPaymentScreen(
          payFrequency: state.pathParameters['frequency']!,
          controller: PayrollPaymentController(
            getCurrentSessionUseCase,
            getPayrollPaymentPreviewUseCase,
            processPayrollPaymentUseCase,
          ),
        ),
      ),
      GoRoute(
        path: '/payroll/history',
        builder: (context, state) => PayrollHistoryScreen(
          controller: PayrollHistoryController(
            getCurrentSessionUseCase,
            getPayrollHistoryUseCase,
            getPayrollReportUseCase,
            payrollPdfService,
          ),
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
        path: '/employees/:employeeId/compensation',
        builder: (context, state) => EmployeeCompensationScreen(
          employeeId: state.pathParameters['employeeId']!,
          controller: EmployeeCompensationController(
            getCurrentSessionUseCase,
            getEmployeeCompensationUseCase,
            updateEmployeeCompensationUseCase,
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
