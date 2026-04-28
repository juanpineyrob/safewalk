import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final usuario = auth.usuario;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeWalk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await context.read<AuthViewModel>().cerrarSesion();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (usuario != null) ...[
                Text(
                  'Hola, ${usuario.nombre}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.verdePrimario,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  usuario.email,
                  style: TextStyle(color: AppTheme.grisSecundario),
                ),
                const SizedBox(height: 32),
              ],
              ElevatedButton.icon(
                onPressed: () => context.push('/mapa'),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Ver mapa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
