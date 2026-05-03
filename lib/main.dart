import 'package:flutter/material.dart';
import 'config/router/app_router.dart';
import 'config/theme/app_theme.dart';
import 'config/theme/theme_controller.dart';
import 'core/database/app_database.dart';
import 'core/helpers/app_error_handler.dart';

Future<void> main() async {
  await AppErrorHandler.run(() async {
    WidgetsFlutterBinding.ensureInitialized();
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
  final AppDatabase database = AppDatabase();
  late final router = appRouter(
    themeController: widget.themeController,
    database: database,
  );

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
