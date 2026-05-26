import 'package:flutter/foundation.dart';

import '../models/ubicacion.dart';
import '../models/zona_peligrosa.dart';
import '../services/ruteo_service.dart';
import '../services/zona_peligrosa_service.dart';

class MapaViewModel extends ChangeNotifier {
  MapaViewModel({
    ZonaPeligrosaService? zonaService,
    RuteoService? ruteoService,
  })  : _zonaService = zonaService ?? ZonaPeligrosaService(),
        _ruteoService = ruteoService ?? RuteoService();

  final ZonaPeligrosaService _zonaService;
  final RuteoService _ruteoService;

  Ubicacion? _ubicacionActual;
  Ubicacion? _destino;
  String? _destinoEtiqueta;
  double _zoom = 15.0;
  List<ZonaPeligrosa> _zonas = [];
  List<RutaCandidata> _rutasAlternativas = [];
  RutaCandidata? _rutaSegura;
  bool _cargandoZonas = false;
  bool _calculandoRuta = false;
  String? _errorRuta;

  Ubicacion? get ubicacionActual => _ubicacionActual;
  Ubicacion? get destino => _destino;
  String? get destinoEtiqueta => _destinoEtiqueta;
  double get zoom => _zoom;
  List<ZonaPeligrosa> get zonas => _zonas;
  List<RutaCandidata> get rutasAlternativas => _rutasAlternativas;
  RutaCandidata? get rutaSegura => _rutaSegura;
  bool get cargandoZonas => _cargandoZonas;
  bool get calculandoRuta => _calculandoRuta;
  String? get errorRuta => _errorRuta;

  void actualizarUbicacion(Ubicacion ubicacion) {
    _ubicacionActual = ubicacion;
    notifyListeners();
  }

  void actualizarZoom(double zoom) {
    _zoom = zoom;
    notifyListeners();
  }

  Future<void> cargarZonas() async {
    _cargandoZonas = true;
    notifyListeners();
    try {
      _zonas = await _zonaService.obtenerZonas();
    } catch (_) {
      _zonas = [];
    } finally {
      _cargandoZonas = false;
      notifyListeners();
    }
  }

  Future<ZonaPeligrosa?> reportarZona({
    required String nombre,
    String? descripcion,
    required String categoria,
    required double lat,
    required double lon,
    required double radioMetros,
  }) async {
    try {
      final zona = await _zonaService.reportarZona(
        nombre: nombre,
        descripcion: descripcion,
        categoria: categoria,
        lat: lat,
        lon: lon,
        radioMetros: radioMetros,
      );
      _zonas = [zona, ..._zonas];
      notifyListeners();
      return zona;
    } catch (_) {
      return null;
    }
  }

  void fijarDestino(Ubicacion destino, {String? etiqueta}) {
    _destino = destino;
    _destinoEtiqueta = etiqueta;
    _rutaSegura = null;
    _rutasAlternativas = [];
    _errorRuta = null;
    notifyListeners();
  }

  void limpiarDestino() {
    _destino = null;
    _destinoEtiqueta = null;
    _rutaSegura = null;
    _rutasAlternativas = [];
    _errorRuta = null;
    notifyListeners();
  }

  Future<void> calcularRutaSegura() async {
    final origen = _ubicacionActual;
    final destino = _destino;
    if (origen == null || destino == null) return;

    _calculandoRuta = true;
    _errorRuta = null;
    notifyListeners();
    try {
      final rutas = await _ruteoService.obtenerRutasConEvasion(
        origen,
        destino,
        _zonas,
      );
      if (rutas.isEmpty) {
        _errorRuta = 'OSRM no devolvió rutas';
        _rutaSegura = null;
        _rutasAlternativas = [];
      } else {
        _rutaSegura = rutas.first;
        _rutasAlternativas = rutas;
      }
    } on RuteoException catch (e) {
      _errorRuta = e.mensaje;
      _rutaSegura = null;
      _rutasAlternativas = [];
    } catch (e) {
      _errorRuta = 'Error de red: $e';
      _rutaSegura = null;
      _rutasAlternativas = [];
    } finally {
      _calculandoRuta = false;
      notifyListeners();
    }
  }
}
