import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/ubicacion.dart';
import '../../models/zona_peligrosa.dart';
import '../../services/gps_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/mapa_viewmodel.dart';
import 'widgets/avatar_button.dart';
import 'widgets/buscar_destino_sheet.dart';
import 'widgets/profile_sheet.dart';
import 'widgets/reportar_zona_dialog.dart';

/// Pantalla principal: el mapa ocupa toda la ventana y los controles flotan
/// como tarjetas suaves. Inspirada en la estética de Apple Maps — sin chrome
/// fijo, jerarquía clara y espacio generoso.
class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  static const _ubicacionPorDefecto = LatLng(-34.9011, -56.1645);
  final _gpsService = GpsService();
  final _mapController = MapController();
  bool _cargando = true;
  String? _errorPermiso;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _cargarUbicacion();
      if (!mounted) return;
      await context.read<MapaViewModel>().cargarZonas();
    });
  }

  Future<void> _cargarUbicacion() async {
    setState(() {
      _cargando = true;
      _errorPermiso = null;
    });
    try {
      final ubicacion = await _gpsService.obtenerUbicacionActual();
      if (!mounted || ubicacion == null) return;
      context.read<MapaViewModel>().actualizarUbicacion(ubicacion);
      _mapController.move(
        LatLng(ubicacion.latitud, ubicacion.longitud),
        16,
      );
    } on GpsPermisoDenegadoException catch (e) {
      if (!mounted) return;
      setState(() => _errorPermiso = e.mensaje);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorPermiso = 'No se pudo obtener la ubicación');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _abrirBuscador() async {
    final seleccion = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BuscarDestinoSheet(),
    );
    if (!mounted || seleccion == null) return;
    final viewModel = context.read<MapaViewModel>();
    viewModel.fijarDestino(
      seleccion.ubicacion as Ubicacion,
      etiqueta: seleccion.etiqueta as String,
    );
    final dest = viewModel.destino!;
    _mapController.move(LatLng(dest.latitud, dest.longitud), 15);
  }

  Future<void> _abrirPerfil() async {
    final usuario = context.read<AuthViewModel>().usuario;
    if (usuario == null) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.superficieAlta,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ProfileSheet(usuario: usuario),
      ),
    );
  }

  Future<void> _trazarRuta() async {
    final viewModel = context.read<MapaViewModel>();
    await viewModel.calcularRutaSegura();
    if (!mounted) return;
    final error = viewModel.errorRuta;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo calcular ruta: $error')),
      );
      return;
    }
    final ruta = viewModel.rutaSegura;
    if (ruta == null) return;
    _ajustarCamaraARuta(ruta.puntos);
  }

  void _ajustarCamaraARuta(List<LatLng> puntos) {
    if (puntos.isEmpty) return;
    final bounds = LatLngBounds.fromPoints(puntos);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(48, 140, 48, 220),
        maxZoom: 17,
      ),
    );
  }

  Future<void> _onLongPress(LatLng punto) async {
    final datos = await showDialog<ReportarZonaDatos>(
      context: context,
      builder: (_) => ReportarZonaDialog(
        lat: punto.latitude,
        lon: punto.longitude,
      ),
    );
    if (!mounted || datos == null) return;
    final viewModel = context.read<MapaViewModel>();
    final zona = await viewModel.reportarZona(
      nombre: datos.nombre,
      descripcion: datos.descripcion,
      categoria: datos.categoria,
      lat: punto.latitude,
      lon: punto.longitude,
      radioMetros: datos.radioMetros,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          zona != null
              ? 'Zona "${zona.nombre}" reportada'
              : 'No se pudo reportar la zona',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MapaViewModel>();
    final usuario = context.watch<AuthViewModel>().usuario;
    final ubicacion = viewModel.ubicacionActual;
    final destino = viewModel.destino;
    final rutaSegura = viewModel.rutaSegura;
    final alternativas = viewModel.rutasAlternativas;
    final zonas = viewModel.zonas;

    final centro = ubicacion != null
        ? LatLng(ubicacion.latitud, ubicacion.longitud)
        : _ubicacionPorDefecto;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: centro,
              initialZoom: ubicacion != null ? 16 : 13,
              minZoom: 3,
              maxZoom: 19,
              onLongPress: (_, latlng) => _onLongPress(latlng),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.safewalk.app',
                maxNativeZoom: 19,
              ),
              if (zonas.isNotEmpty)
                CircleLayer(
                  circles: zonas.map(_circuloZona).toList(),
                ),
              if (alternativas.length > 1)
                PolylineLayer(
                  polylines: alternativas
                      .where((r) => r != rutaSegura)
                      .map(
                        (r) => Polyline(
                          points: r.puntos,
                          color: AppTheme.grisTerciario.withValues(alpha: 0.45),
                          strokeWidth: 4,
                          borderStrokeWidth: 1,
                          borderColor: AppTheme.blanco,
                        ),
                      )
                      .toList(),
                ),
              if (rutaSegura != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: rutaSegura.puntos,
                      color: AppTheme.verdePrimario,
                      strokeWidth: 6,
                      borderStrokeWidth: 2,
                      borderColor: AppTheme.blanco,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (ubicacion != null) _markerUbicacion(ubicacion),
                  if (destino != null) _markerDestino(destino),
                ],
              ),
            ],
          ),

          // Header flotante con búsqueda + avatar
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: _FloatingSearchHeader(
              cargando: _cargando,
              destinoEtiqueta: viewModel.destinoEtiqueta,
              nombreUsuario: usuario?.nombre ?? '?',
              onSearchTap: _cargando ? null : _abrirBuscador,
              onAvatarTap: _abrirPerfil,
            ),
          ),

          // Banner de error de permisos
          if (_errorPermiso != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 88,
              left: 16,
              right: 16,
              child: _AvisoError(mensaje: _errorPermiso!),
            ),

          // Sheet inferior con destino + ruta
          if (destino != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24 + MediaQuery.of(context).padding.bottom,
              child: _DestinoCard(
                viewModel: viewModel,
                onTrazar: _trazarRuta,
                onLimpiar: viewModel.limpiarDestino,
              ),
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: destino != null ? 180 : 16,
          right: 4,
        ),
        child: _MapFab(
          onPressed: _cargando ? null : _cargarUbicacion,
          icono: Icons.near_me_outlined,
          tooltip: 'Centrar en mi ubicación',
        ),
      ),
    );
  }

  CircleMarker _circuloZona(ZonaPeligrosa zona) {
    return CircleMarker(
      point: LatLng(zona.ubicacion.latitud, zona.ubicacion.longitud),
      radius: zona.radioMetros,
      useRadiusInMeter: true,
      color: AppTheme.rojoError.withValues(alpha: 0.18),
      borderColor: AppTheme.rojoError.withValues(alpha: 0.85),
      borderStrokeWidth: 1.5,
    );
  }

  Marker _markerUbicacion(Ubicacion ubicacion) {
    return Marker(
      point: LatLng(ubicacion.latitud, ubicacion.longitud),
      width: 36,
      height: 36,
      child: const _PulsoUbicacion(),
    );
  }

  Marker _markerDestino(Ubicacion destino) {
    return Marker(
      point: LatLng(destino.latitud, destino.longitud),
      width: 44,
      height: 56,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.verdePrimario,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.blanco, width: 3),
              boxShadow: AppTheme.sombraSuave,
            ),
            child: const Icon(Icons.flag_rounded,
                color: AppTheme.blanco, size: 14),
          ),
          Container(
            width: 2,
            height: 14,
            color: AppTheme.verdePrimario,
          ),
        ],
      ),
    );
  }
}

// ─── Header flotante con búsqueda y avatar ────────────────────────────────

class _FloatingSearchHeader extends StatelessWidget {
  const _FloatingSearchHeader({
    required this.cargando,
    required this.destinoEtiqueta,
    required this.nombreUsuario,
    required this.onSearchTap,
    required this.onAvatarTap,
  });

  final bool cargando;
  final String? destinoEtiqueta;
  final String nombreUsuario;
  final VoidCallback? onSearchTap;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.superficieAlta,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.sombraFlotante,
      ),
      padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(22),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onSearchTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      if (cargando)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.grisTerciario,
                          ),
                        )
                      else
                        const Icon(
                          Icons.search_rounded,
                          size: 22,
                          color: AppTheme.grisSecundario,
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          destinoEtiqueta ?? '¿A dónde vamos?',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: destinoEtiqueta != null
                                    ? AppTheme.grisTexto
                                    : AppTheme.grisTerciario,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(width: 1, height: 28, color: AppTheme.outlineSuave),
          const SizedBox(width: 6),
          AvatarButton(nombre: nombreUsuario, onTap: onAvatarTap, size: 36),
          const SizedBox(width: 2),
        ],
      ),
    );
  }
}

// ─── Marker de ubicación con pulso ────────────────────────────────────────

class _PulsoUbicacion extends StatefulWidget {
  const _PulsoUbicacion();

  @override
  State<_PulsoUbicacion> createState() => _PulsoUbicacionState();
}

class _PulsoUbicacionState extends State<_PulsoUbicacion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = Curves.easeOut.transform(_c.value);
        return Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: (1 - t) * 0.5,
              child: Container(
                width: 36 * (0.5 + t),
                height: 36 * (0.5 + t),
                decoration: const BoxDecoration(
                  color: AppTheme.verdeClaro,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppTheme.verdePrimario,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.blanco, width: 3),
                boxShadow: AppTheme.sombraSuave,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── FAB minimalista ──────────────────────────────────────────────────────

class _MapFab extends StatelessWidget {
  const _MapFab({
    required this.onPressed,
    required this.icono,
    required this.tooltip,
  });

  final VoidCallback? onPressed;
  final IconData icono;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.superficieAlta,
        shape: BoxShape.circle,
        boxShadow: AppTheme.sombraFlotante,
      ),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        iconSize: 22,
        padding: const EdgeInsets.all(14),
        icon: Icon(icono, color: AppTheme.grisTexto),
      ),
    );
  }
}

// ─── Tarjeta inferior con destino y ruta ─────────────────────────────────

class _DestinoCard extends StatelessWidget {
  const _DestinoCard({
    required this.viewModel,
    required this.onTrazar,
    required this.onLimpiar,
  });

  final MapaViewModel viewModel;
  final VoidCallback onTrazar;
  final VoidCallback onLimpiar;

  @override
  Widget build(BuildContext context) {
    final ruta = viewModel.rutaSegura;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.superficieAlta,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.sombraFlotante,
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.verdeSuave,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppTheme.verdePrimario,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Destino',
                      style: theme.textTheme.labelMedium?.copyWith(
                            color: AppTheme.grisTerciario,
                            letterSpacing: 0.6,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      viewModel.destinoEtiqueta ?? 'Punto seleccionado',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onLimpiar,
                tooltip: 'Quitar destino',
                icon: const Icon(Icons.close_rounded),
                color: AppTheme.grisSecundario,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          if (ruta != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.verdeSuave.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _RutaMetric(
                    valor:
                        '${(ruta.distanciaMetros / 1000).toStringAsFixed(2)}',
                    unidad: 'km',
                  ),
                  _RutaDivider(),
                  _RutaMetric(
                    valor:
                        '${(ruta.duracionSegundos / 60).round()}',
                    unidad: 'min',
                  ),
                  _RutaDivider(),
                  _RutaMetric(
                    valor: '${ruta.intrusiones}',
                    unidad: 'zonas',
                    destructivo: ruta.intrusiones > 0,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: viewModel.calculandoRuta ? null : onTrazar,
            icon: viewModel.calculandoRuta
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.route_rounded, size: 20),
            label: Text(
              ruta == null ? 'Trazar ruta segura' : 'Recalcular',
            ),
          ),
        ],
      ),
    );
  }
}

class _RutaMetric extends StatelessWidget {
  const _RutaMetric({
    required this.valor,
    required this.unidad,
    this.destructivo = false,
  });

  final String valor;
  final String unidad;
  final bool destructivo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = destructivo ? AppTheme.rojoError : AppTheme.verdeOscuro;
    return Expanded(
      child: Column(
        children: [
          Text(
            valor,
            style: theme.textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            unidad,
            style: theme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.grisSecundario,
                  letterSpacing: 0.6,
                ),
          ),
        ],
      ),
    );
  }
}

class _RutaDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: AppTheme.outlineSuave,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

// ─── Aviso de error ───────────────────────────────────────────────────────

class _AvisoError extends StatelessWidget {
  const _AvisoError({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAE9EB),
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.sombraSuave,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppTheme.rojoError,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.rojoError,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
