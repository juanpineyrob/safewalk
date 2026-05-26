import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/ubicacion.dart';

class GpsPermisoDenegadoException implements Exception {
  GpsPermisoDenegadoException(this.mensaje);
  final String mensaje;
  @override
  String toString() => mensaje;
}

class GpsService {
  // Centro de Montevideo. Se usa como ubicación fija en web para que la
  // demo de "ruta segura" sea reproducible sin depender del soporte de
  // geolocation del navegador (que es inconsistente entre Chrome/Firefox/Safari).
  static const double _demoLat = -34.9011;
  static const double _demoLon = -56.1645;

  bool rastreandoEnBackground = false;

  Future<Ubicacion?> obtenerUbicacionActual() async {
    if (kIsWeb) {
      // Disparamos el popup del navegador para mantener el flujo de UX,
      // pero el resultado se descarta y devolvemos una posición fija.
      await _pedirPermisoWebSilencioso();
      return Ubicacion(
        latitud: _demoLat,
        longitud: _demoLon,
        timestamp: DateTime.now(),
      );
    }

    await _asegurarPermisos();
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      return _toUbicacion(position);
    } on PermissionDeniedException catch (e) {
      throw GpsPermisoDenegadoException(
        'Permiso de ubicación denegado: ${e.message}',
      );
    } on LocationServiceDisabledException {
      throw GpsPermisoDenegadoException(
        'El servicio de ubicación está desactivado',
      );
    }
  }

  Stream<Ubicacion> iniciarRastreo() async* {
    if (kIsWeb) {
      await _pedirPermisoWebSilencioso();
      yield Ubicacion(
        latitud: _demoLat,
        longitud: _demoLon,
        timestamp: DateTime.now(),
      );
      return;
    }

    await _asegurarPermisos();
    final stream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );
    rastreandoEnBackground = true;
    yield* stream.map(_toUbicacion);
  }

  Future<void> detenerRastreo() async {
    rastreandoEnBackground = false;
  }

  double calcularDistancia(Ubicacion a, Ubicacion b) {
    return Geolocator.distanceBetween(
      a.latitud,
      a.longitud,
      b.latitud,
      b.longitud,
    );
  }

  Future<void> _asegurarPermisos() async {
    final servicioActivo = await Geolocator.isLocationServiceEnabled();
    if (!servicioActivo) {
      throw GpsPermisoDenegadoException(
        'El servicio de ubicación está desactivado',
      );
    }
    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso == LocationPermission.denied) {
      throw GpsPermisoDenegadoException(
        'Permiso de ubicación denegado',
      );
    }
    if (permiso == LocationPermission.deniedForever) {
      throw GpsPermisoDenegadoException(
        'Permiso de ubicación denegado permanentemente. Habilítalo desde ajustes.',
      );
    }
  }

  Future<void> _pedirPermisoWebSilencioso() async {
    try {
      final permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    } catch (e) {
      debugPrint('gps web: permiso ignorado por error: $e');
    }
  }

  Ubicacion _toUbicacion(Position p) => Ubicacion(
        latitud: p.latitude,
        longitud: p.longitude,
        timestamp: p.timestamp,
      );
}
