import '../models/zona_peligrosa.dart';
import 'api_client.dart';

class ZonaPeligrosaService {
  ZonaPeligrosaService({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<List<ZonaPeligrosa>> obtenerZonas() async {
    final response = await _api.get('/zonas');
    final raw = response['zonas'] as List<dynamic>? ?? const [];
    return raw
        .map((z) => ZonaPeligrosa.fromJson(z as Map<String, dynamic>))
        .toList();
  }

  Future<ZonaPeligrosa> reportarZona({
    required String nombre,
    String? descripcion,
    required String categoria,
    required double lat,
    required double lon,
    required double radioMetros,
  }) async {
    final response = await _api.post('/zonas', body: {
      'nombre': nombre,
      if (descripcion != null && descripcion.isNotEmpty)
        'descripcion': descripcion,
      'categoria': categoria,
      'lat': lat,
      'lon': lon,
      'radioMetros': radioMetros.round(),
    });
    return ZonaPeligrosa.fromJson(
      response['zona'] as Map<String, dynamic>,
    );
  }
}
