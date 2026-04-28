import 'package:go_router/go_router.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/registro_screen.dart';
import '../../views/home/home_screen.dart';
import '../../views/mapa/mapa_screen.dart';

class AppRouter {
  AppRouter._();

  static GoRouter build(AuthViewModel auth) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: auth,
      redirect: (context, state) {
        final autenticado = auth.autenticado;
        final enRutaAuth = state.matchedLocation == '/login' ||
            state.matchedLocation == '/registro';
        if (!autenticado && !enRutaAuth) return '/login';
        if (autenticado && enRutaAuth) return '/home';
        return null;
      },
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
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/mapa',
          name: 'mapa',
          builder: (context, state) => const MapaScreen(),
        ),
      ],
    );
  }
}
