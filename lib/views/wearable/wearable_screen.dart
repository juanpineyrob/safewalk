import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/mapa_viewmodel.dart';
import 'watch_face.dart';

/// Pantalla contenedora que aloja la simulación del smartwatch.
///
/// El reloj (250×250 circular) flota centrado sobre la superficie del tema.
/// Lee del [MapaViewModel] el destino y la ruta segura activa, si los hay,
/// y refleja un toggle local de "ruta en marcha" sobre el botón core.
class WearableScreen extends StatefulWidget {
  const WearableScreen({super.key});

  @override
  State<WearableScreen> createState() => _WearableScreenState();
}

class _WearableScreenState extends State<WearableScreen> {
  bool _enMarcha = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MapaViewModel>();
    final ruta = viewModel.rutaSegura;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Volver',
          onPressed: () => context.pop(),
        ),
        title: const Text('Vista wearable'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
              child: Text(
                'Simulación de pantalla 250×250',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.grisTerciario,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.sombraFlotante,
                  ),
                  child: WatchFace(
                    destinoEtiqueta: viewModel.destinoEtiqueta ??
                        (viewModel.destino != null ? 'Destino' : null),
                    distanciaMetros: ruta?.distanciaMetros,
                    duracionSegundos: ruta?.duracionSegundos,
                    enMarcha: _enMarcha,
                    onToggle: () => setState(() => _enMarcha = !_enMarcha),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: Text(
                _enMarcha
                    ? 'Ruta en marcha — toca el reloj para pausar.'
                    : 'Toca el botón del reloj para iniciar la ruta.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.grisSecundario,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
