import 'package:go_router/go_router.dart';

import '../../views/auth/login_screen.dart';
import '../../views/auth/registro_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/registro',
        name: 'registro',
        builder: (context, state) => const RegistroScreen(),
      ),
    ],
  );
}
