import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Avatar circular con la inicial del usuario.
///
/// Usado como entrada al panel de cuenta desde la barra de búsqueda flotante.
class AvatarButton extends StatelessWidget {
  const AvatarButton({
    super.key,
    required this.nombre,
    required this.onTap,
    this.size = 36,
  });

  final String nombre;
  final VoidCallback onTap;
  final double size;

  String get _inicial {
    final t = nombre.trim();
    if (t.isEmpty) return '?';
    return t.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Cuenta de $nombre',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.verdePrimario, AppTheme.verdeClaro],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.blanco, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              _inicial,
              style: TextStyle(
                color: AppTheme.blanco,
                fontSize: size * 0.42,
                fontWeight: FontWeight.w600,
                height: 1,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
