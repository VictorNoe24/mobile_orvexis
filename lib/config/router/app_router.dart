import 'package:go_router/go_router.dart';
import 'package:mobile_orvexis/config/theme/theme_controller.dart';
import 'package:mobile_orvexis/core/database/app_database.dart';
import '../../feature/auth/presentation/screens/login_screen.dart';
import '../../feature/home/presentation/screens/home_screen.dart';
import '../../feature/splash/presentation/screens/splash_screen.dart';

GoRouter appRouter({
  required ThemeController themeController,
  required AppDatabase database,
}) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashScreen(database: database),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/home',
        builder: (context, state) =>
            HomeScreen(themeController: themeController, database: database),
      ),
    ],
  );
}
