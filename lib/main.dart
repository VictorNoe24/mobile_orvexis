import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/router/app_router.dart';
import 'config/theme/app_theme.dart';
import 'config/theme/theme_controller.dart';
import 'core/database/app_database.dart';
import 'core/helpers/app_error_handler.dart';

Future<void> main() async {
  await AppErrorHandler.run(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('es_MX');
    final themeController = ThemeController();
    await themeController.loadSavedThemeMode();
    runApp(MyApp(themeController: themeController));
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppDatabase database;
  late GoRouter router;
  int _appGeneration = 0;

  @override
  void initState() {
    super.initState();
    _createRuntime();
  }

  void _createRuntime() {
    database = AppDatabase();
    router = appRouter(
      themeController: widget.themeController,
      database: database,
      onDatabaseRestore: _restoreDatabase,
    );
  }

  Future<void> _restoreDatabase(Future<void> Function() restore) async {
    await database.close();
    try {
      await restore();
    } finally {
      if (mounted) {
        setState(() {
          _appGeneration++;
          _createRuntime();
        });
      }
    }
  }

  @override
  void dispose() {
    database.close();
    widget.themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.themeController,
      builder: (context, _) {
        return MaterialApp.router(
          key: ValueKey(_appGeneration),
          debugShowCheckedModeBanner: false,
          title: 'Mobile Orvexis',
          routerConfig: router,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: widget.themeController.themeMode,
        );
      },
    );
  }
}
