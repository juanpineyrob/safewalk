import 'package:go_router/go_router.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/registro_screen.dart';
import '../../views/mapa/mapa_screen.dart';
import '../../views/settings/settings_screen.dart';
import '../../views/wearable/wearable_screen.dart';

class AppRouter {
  AppRouter._();

  static GoRouter build(AuthViewModel auth) {
    return GoRouter(
      initialLocation: '/mapa',
      refreshListenable: auth,
      redirect: (context, state) {
        final autenticado = auth.autenticado;
        final enRutaAuth = state.matchedLocation == '/login' ||
            state.matchedLocation == '/registro';
        if (!autenticado && !enRutaAuth) return '/login';
        if (autenticado && enRutaAuth) return '/mapa';
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
          path: '/mapa',
          name: 'mapa',
          builder: (context, state) => const MapaScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/wearable',
          name: 'wearable',
          builder: (context, state) => const WearableScreen(),
        ),
      ],
    );
  }
}
