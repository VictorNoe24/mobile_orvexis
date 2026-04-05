import 'package:go_router/go_router.dart';
import 'package:mobile_orvexis/config/theme/theme_controller.dart';
import '../../feature/auth/presentation/screens/login_screen.dart';
import '../../feature/home/presentation/screens/home_screen.dart';

GoRouter appRouter(ThemeController themeController) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => HomeScreen(
          themeController: themeController,
        ),
      ),
    ],
  );
}
