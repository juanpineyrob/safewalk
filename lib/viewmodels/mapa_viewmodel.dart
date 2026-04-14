import 'package:flutter/foundation.dart';

import '../models/ubicacion.dart';
import '../models/zona_peligrosa.dart';

class MapaViewModel extends ChangeNotifier {
  Ubicacion? _ubicacionActual;
  double _zoom = 15.0;
  List<ZonaPeligrosa> _zonasVisibles = [];

  Ubicacion? get ubicacionActual => _ubicacionActual;
  double get zoom => _zoom;
  List<ZonaPeligrosa> get zonasVisibles => _zonasVisibles;

  void actualizarUbicacion(Ubicacion ubicacion) {
    _ubicacionActual = ubicacion;
    notifyListeners();
  }

  void actualizarZoom(double zoom) {
    _zoom = zoom;
    notifyListeners();
  }

  void cargarZonas(List<ZonaPeligrosa> zonas) {
    _zonasVisibles = zonas;
    notifyListeners();
  }
}
