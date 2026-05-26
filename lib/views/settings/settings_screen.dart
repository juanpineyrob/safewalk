import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/usuario.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../mapa/widgets/avatar_button.dart';

/// Pantalla de configuración completa.
///
/// Layout: cabecera con avatar grande + datos del usuario, seguida de
/// secciones (Cuenta, Preferencias, Acerca) con tiles de lista uniformes.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final usuario = auth.usuario;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Volver',
          onPressed: () => context.pop(),
        ),
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          if (usuario != null) _Cabecera(theme: theme, usuario: usuario),
          const SizedBox(height: 28),
          _Seccion(
            titulo: 'Cuenta',
            opciones: [
              _OpcionData(
                icono: Icons.badge_outlined,
                titulo: 'Información personal',
                subtitulo: 'Nombre, foto y datos de contacto',
                onTap: () => _proximamente(context),
              ),
              _OpcionData(
                icono: Icons.lock_outline_rounded,
                titulo: 'Seguridad',
                subtitulo: 'Contraseña y sesiones activas',
                onTap: () => _proximamente(context),
              ),
              _OpcionData(
                icono: Icons.workspace_premium_outlined,
                titulo: 'Plan',
                trailing: _Etiqueta(
                  texto: usuario?.tipoCuenta.name ?? '—',
                ),
                onTap: () => _proximamente(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _Seccion(
            titulo: 'Preferencias',
            opciones: [
              _OpcionData(
                icono: Icons.notifications_none_rounded,
                titulo: 'Notificaciones',
                subtitulo: 'Alertas de zonas y caminatas',
                onTap: () => _proximamente(context),
              ),
              _OpcionData(
                icono: Icons.map_outlined,
                titulo: 'Mapa',
                subtitulo: 'Estilo, capas y radio de alertas',
                onTap: () => _proximamente(context),
              ),
              _OpcionData(
                icono: Icons.privacy_tip_outlined,
                titulo: 'Privacidad',
                subtitulo: 'Quién ve tus reportes y caminatas',
                onTap: () => _proximamente(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _Seccion(
            titulo: 'Acerca',
            opciones: [
              _OpcionData(
                icono: Icons.info_outline_rounded,
                titulo: 'Sobre SafeWalk',
                trailing: _Etiqueta(texto: 'v0.1.0'),
                onTap: () => _proximamente(context),
              ),
              _OpcionData(
                icono: Icons.description_outlined,
                titulo: 'Términos y privacidad',
                onTap: () => _proximamente(context),
              ),
            ],
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () async {
              await context.read<AuthViewModel>().cerrarSesion();
              if (context.mounted) context.go('/login');
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFAE9EB),
              foregroundColor: AppTheme.rojoError,
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  void _proximamente(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Próximamente disponible')),
    );
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera({required this.theme, required this.usuario});

  final ThemeData theme;
  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AvatarButton(nombre: usuario.nombre, size: 88, onTap: () {}),
        const SizedBox(height: 18),
        Text(
          usuario.nombre,
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          usuario.email,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.verdeSuave,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.verdeClaro,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Activo',
                style: theme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.verdeOscuro,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo, required this.opciones});

  final String titulo;
  final List<_OpcionData> opciones;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
          child: Text(
            titulo.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.grisTerciario,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.superficieAlta,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.outlineSuave),
          ),
          child: Column(
            children: [
              for (var i = 0; i < opciones.length; i++) ...[
                _OpcionTile(opcion: opciones[i]),
                if (i < opciones.length - 1)
                  const Padding(
                    padding: EdgeInsets.only(left: 64),
                    child: Divider(),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _OpcionData {
  const _OpcionData({
    required this.icono,
    required this.titulo,
    required this.onTap,
    this.subtitulo,
    this.trailing,
  });

  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final Widget? trailing;
  final VoidCallback onTap;
}

class _OpcionTile extends StatelessWidget {
  const _OpcionTile({required this.opcion});

  final _OpcionData opcion;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: opcion.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.verdeSuave,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(opcion.icono,
                  color: AppTheme.verdePrimario, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opcion.titulo,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (opcion.subtitulo != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      opcion.subtitulo!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            if (opcion.trailing != null) ...[
              opcion.trailing!,
              const SizedBox(width: 6),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.grisTerciario,
            ),
          ],
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.superficieSuave,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.grisSecundario,
              letterSpacing: 0.4,
            ),
      ),
    );
  }
}
