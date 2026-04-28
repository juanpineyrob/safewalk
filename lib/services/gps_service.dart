import 'package:geolocator/geolocator.dart';

import '../models/ubicacion.dart';

class GpsPermisoDenegadoException implements Exception {
  GpsPermisoDenegadoException(this.mensaje);
  final String mensaje;
  @override
  String toString() => mensaje;
}

class GpsService {
  bool rastreandoEnBackground = false;

  Future<Ubicacion?> obtenerUbicacionActual() async {
    await _asegurarPermisos();
    final position = await Geolocator.getCurrentPosition(
      locationSettings:
          const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return _toUbicacion(position);
  }

  Stream<Ubicacion> iniciarRastreo() async* {
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

  Ubicacion _toUbicacion(Position p) => Ubicacion(
        latitud: p.latitude,
        longitud: p.longitude,
        timestamp: p.timestamp,
      );
}
