import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/ubicacion.dart';
import '../../services/gps_service.dart';
import '../../viewmodels/mapa_viewmodel.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  static const _ubicacionPorDefecto = LatLng(-34.9011, -56.1645); // Montevideo
  final _gpsService = GpsService();
  final _mapController = MapController();
  bool _cargando = true;
  String? _errorPermiso;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarUbicacion());
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

  @override
  Widget build(BuildContext context) {
    final ubicacion = context.watch<MapaViewModel>().ubicacionActual;
    final centro = ubicacion != null
        ? LatLng(ubicacion.latitud, ubicacion.longitud)
        : _ubicacionPorDefecto;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: centro,
              initialZoom: ubicacion != null ? 16 : 13,
              minZoom: 3,
              maxZoom: 19,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.safewalk.app',
                maxNativeZoom: 19,
              ),
              if (ubicacion != null)
                MarkerLayer(
                  markers: [_markerUbicacion(ubicacion)],
                ),
            ],
          ),
          if (_cargando)
            const Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Obteniendo ubicación...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_errorPermiso != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: AppTheme.rojoError,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.location_off, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorPermiso!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _cargando ? null : _cargarUbicacion,
        backgroundColor: AppTheme.verdePrimario,
        tooltip: 'Centrar en mi ubicación',
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Marker _markerUbicacion(Ubicacion ubicacion) {
    return Marker(
      point: LatLng(ubicacion.latitud, ubicacion.longitud),
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.verdePrimario,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.person_pin, color: Colors.white, size: 20),
      ),
    );
  }
}
