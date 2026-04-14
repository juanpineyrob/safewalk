import 'package:flutter/foundation.dart';

import '../models/caminata.dart';
import '../models/ubicacion.dart';
import '../services/caminata_service.dart';

class CaminataViewModel extends ChangeNotifier {
  final CaminataService _caminataService = CaminataService();

  Caminata? _caminataActual;
  List<Caminata> _historial = [];
  bool _cargando = false;

  Caminata? get caminataActual => _caminataActual;
  List<Caminata> get historial => _historial;
  bool get cargando => _cargando;
  bool get caminataActiva => _caminataActual?.activa ?? false;

  Future<void> cargarHistorial(String usuarioId) async {
    _cargando = true;
    notifyListeners();

    _historial = await _caminataService.obtenerHistorial(usuarioId);
    _cargando = false;
    notifyListeners();
  }

  void registrarPunto(Ubicacion ubicacion) {
    // TODO: Agregar punto al recorrido activo
    notifyListeners();
  }
}
