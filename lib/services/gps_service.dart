import '../models/ubicacion.dart';

class GpsService {
  bool rastreandoEnBackground = false;

  Future<Ubicacion?> obtenerUbicacionActual() async {
    // TODO: Implementar con geolocator
    return null;
  }

  Future<void> iniciarRastreo() async {
    // TODO: Implementar rastreo continuo
  }

  Future<void> detenerRastreo() async {
    // TODO: Detener rastreo
  }

  double calcularDistancia(Ubicacion a, Ubicacion b) {
    // TODO: Implementar cálculo de distancia
    return 0;
  }
}
