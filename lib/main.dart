import 'package:flutter/material.dart';
import 'config/router/app_router.dart';
import 'config/theme/app_theme.dart';
import 'config/theme/theme_controller.dart';
import 'core/helpers/app_error_handler.dart';

Future<void> main() async {
  await AppErrorHandler.run(() async {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeController themeController = ThemeController();
  late final router = appRouter(themeController);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Mobile Orvexis',
          routerConfig: router,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
        );
      },
    );
  }
}
