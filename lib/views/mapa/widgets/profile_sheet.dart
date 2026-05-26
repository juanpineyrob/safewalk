import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/usuario.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import 'avatar_button.dart';

/// Panel compacto con información básica del usuario.
///
/// Se abre desde el avatar de la barra flotante. Incluye botón a
/// "Configuración" (pantalla completa) y un atajo a "Cerrar sesión".
class ProfileSheet extends StatelessWidget {
  const ProfileSheet({super.key, required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AvatarButton(
                  nombre: usuario.nombre,
                  size: 56,
                  onTap: () {},
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        usuario.nombre,
                        style: theme.textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        usuario.email,
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ChipEstado(tipoCuenta: usuario.tipoCuenta.name),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 8),
            _OpcionPanel(
              icono: Icons.settings_outlined,
              titulo: 'Configuración',
              subtitulo: 'Cuenta, preferencias y privacidad',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/settings');
              },
            ),
            _OpcionPanel(
              icono: Icons.logout_rounded,
              titulo: 'Cerrar sesión',
              destructivo: true,
              onTap: () async {
                Navigator.of(context).pop();
                await context.read<AuthViewModel>().cerrarSesion();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipEstado extends StatelessWidget {
  const _ChipEstado({required this.tipoCuenta});

  final String tipoCuenta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.verdeSuave,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.verdeClaro,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Sesión activa',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.verdeOscuro,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          Text(
            tipoCuenta,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.verdeOscuro,
                  letterSpacing: 0.6,
                ),
          ),
        ],
      ),
    );
  }
}

class _OpcionPanel extends StatelessWidget {
  const _OpcionPanel({
    required this.icono,
    required this.titulo,
    required this.onTap,
    this.subtitulo,
    this.destructivo = false,
  });

  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final VoidCallback onTap;
  final bool destructivo;

  @override
  Widget build(BuildContext context) {
    final color = destructivo ? AppTheme.rojoError : AppTheme.grisTexto;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: destructivo
                      ? const Color(0xFFFAE9EB)
                      : AppTheme.superficieSuave,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(icono, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: color,
                          ),
                    ),
                    if (subtitulo != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitulo!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (!destructivo)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.grisTerciario,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
