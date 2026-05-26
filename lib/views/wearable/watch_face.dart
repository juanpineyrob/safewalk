import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Viewport circular de 250×250 px que simula la pantalla de un smartwatch.
///
/// Respeta las "Reglas de Ouro" para wearables:
///   • Fondo negro OLED.
///   • Alto contraste (blanco + verde vibrante).
///   • Sin entradas de texto.
///   • 1–2 elementos interactivos enfocados en la acción core.
class WatchFace extends StatelessWidget {
  const WatchFace({
    super.key,
    required this.destinoEtiqueta,
    required this.distanciaMetros,
    required this.duracionSegundos,
    required this.enMarcha,
    required this.onToggle,
  });

  final String? destinoEtiqueta;
  final double? distanciaMetros;
  final double? duracionSegundos;
  final bool enMarcha;
  final VoidCallback onToggle;

  static const double _diametro = 250;

  @override
  Widget build(BuildContext context) {
    final hayRuta = destinoEtiqueta != null;

    return ClipOval(
      child: Container(
        width: _diametro,
        height: _diametro,
        color: Colors.black,
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: hayRuta ? _contenidoRuta(context) : _contenidoVacio(context),
        ),
      ),
    );
  }

  Widget _contenidoRuta(BuildContext context) {
    final etiqueta = _truncar(destinoEtiqueta!, 14);
    final km = (distanciaMetros ?? 0) / 1000;
    final min = ((duracionSegundos ?? 0) / 60).round();
    final hayMetricas = distanciaMetros != null && duracionSegundos != null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          etiqueta,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          hayMetricas
              ? '${km.toStringAsFixed(1)} km · $min min'
              : 'Sin ruta trazada',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: hayMetricas
                ? AppTheme.verdeClaro
                : Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 18),
        _BotonCore(enMarcha: enMarcha, onTap: onToggle),
      ],
    );
  }

  Widget _contenidoVacio(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.location_off_outlined,
          color: Colors.white,
          size: 40,
        ),
        const SizedBox(height: 14),
        const Text(
          'Sin ruta activa',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Fija un destino\nen el mapa',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  String _truncar(String texto, int max) {
    if (texto.length <= max) return texto;
    return '${texto.substring(0, max - 1)}…';
  }
}

class _BotonCore extends StatelessWidget {
  const _BotonCore({required this.enMarcha, required this.onTap});

  final bool enMarcha;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enMarcha ? AppTheme.rojoError : AppTheme.verdeClaro;
    final label = enMarcha ? 'PAUSAR' : 'INICIAR';
    final icono = enMarcha ? Icons.pause_rounded : Icons.play_arrow_rounded;

    return Material(
      color: color,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 170,
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
