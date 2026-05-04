import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_orvexis/config/theme/theme_controller.dart';
import 'package:mobile_orvexis/feature/auth/domain/entities/auth_session.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/logout_usecase.dart';
import 'package:mobile_orvexis/feature/employees/presentation/screens/employees_screen.dart';
import 'package:mobile_orvexis/feature/home/presentation/widgets/home_dashboard_tab.dart';
import 'package:mobile_orvexis/feature/home/presentation/widgets/home_placeholder_tab.dart';
import 'package:mobile_orvexis/feature/home/presentation/widgets/home_settings_tab.dart';
import 'package:mobile_orvexis/feature/employees/infrastructure/datasources/employees_local_datasource.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.themeController,
    required this.getCurrentSessionUseCase,
    required this.logoutUseCase,
    required this.employeesLocalDataSource,
  });

  final ThemeController themeController;
  final GetCurrentSessionUseCase getCurrentSessionUseCase;
  final LogoutUseCase logoutUseCase;
  final EmployeesLocalDataSource employeesLocalDataSource;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Future<void> _handleManageRoles() async {
    await context.push('/roles');
  }

  Future<void> _handleLogout() async {
    await widget.logoutUseCase();
    if (!mounted) return;
    context.go('/start');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? null
          : AppBar(
              title: Text(_titles[_selectedIndex]),
              actions: _selectedIndex == 4
                  ? [
                      TextButton(
                        onPressed: _handleLogout,
                        child: const Text('Cerrar sesion'),
                      ),
                    ]
                  : null,
            ),
      body: FutureBuilder<AuthSession?>(
        future: widget.getCurrentSessionUseCase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error al cargar la sesion: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final session = snapshot.data;
          if (session == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No se encontro una sesion activa.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return _buildTabContent(session);
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Inicio'),
          NavigationDestination(
            icon: Icon(Icons.groups_rounded),
            label: 'Empleados',
          ),
          NavigationDestination(
            icon: Icon(Icons.apartment_rounded),
            label: 'Proyectos',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_rounded),
            label: 'Nominas',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_rounded),
            label: 'Ajustes',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () => context.push('/employees/create'),
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }

  Widget _buildTabContent(AuthSession session) {
    switch (_selectedIndex) {
      case 0:
        return HomeDashboardTab(session: session);
      case 1:
        return EmployeesScreen(
          getCurrentSessionUseCase: widget.getCurrentSessionUseCase,
          employeesLocalDataSource: widget.employeesLocalDataSource,
        );
      case 4:
        return HomeSettingsTab(
          themeController: widget.themeController,
          onManageRoles: _handleManageRoles,
          onLogout: _handleLogout,
        );
      default:
        return HomePlaceholderTab(title: _titles[_selectedIndex]);
    }
  }
}

const List<String> _titles = [
  'Inicio',
  'Empleados',
  'Proyectos',
  'Nominas',
  'Ajustes',
];
