import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_orvexis/config/theme/theme_controller.dart';
import 'package:mobile_orvexis/feature/auth/domain/entities/auth_session.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/logout_usecase.dart';

class HomeScreen extends StatefulWidget {
  final ThemeController themeController;
  final GetCurrentSessionUseCase getCurrentSessionUseCase;
  final LogoutUseCase logoutUseCase;

  const HomeScreen({
    super.key,
    required this.themeController,
    required this.getCurrentSessionUseCase,
    required this.logoutUseCase,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Future<void> _handleLogout() async {
    await widget.logoutUseCase();
    if (!mounted) return;
    context.go('/start');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
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

          return _buildTabContent(
            context: context,
            theme: theme,
            colors: colors,
            session: session,
          );
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
    );
  }

  Widget _buildTabContent({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme colors,
    required AuthSession session,
  }) {
    switch (_selectedIndex) {
      case 0:
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sesion actual',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('ID de usuario: ${session.userId}'),
                    const SizedBox(height: 6),
                    Text('Correo: ${session.email}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'La informacion mostrada proviene de la sesion persistida del usuario autenticado.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        );
      case 4:
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.dark_mode, color: colors.primary),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Modo oscuro')),
                    Switch(
                      value: widget.themeController.themeMode == ThemeMode.dark,
                      onChanged: widget.themeController.toggleTheme,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Cerrar sesion'),
            ),
          ],
        );
      default:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'La seccion "${_titles[_selectedIndex]}" estara disponible pronto.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        );
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
