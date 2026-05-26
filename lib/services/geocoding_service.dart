import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ubicacion.dart';

class SugerenciaLugar {
  final String etiqueta;
  final Ubicacion ubicacion;

  const SugerenciaLugar({required this.etiqueta, required this.ubicacion});
}

class GeocodingService {
  GeocodingService({http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final http.Client _http;

  static const _base = 'https://nominatim.openstreetmap.org';

  Future<List<SugerenciaLugar>> buscar(String query) async {
    final q = query.trim();
    if (q.length < 3) return const [];
    final uri = Uri.parse(
      '$_base/search?q=${Uri.encodeQueryComponent(q)}'
      '&format=json&limit=5&countrycodes=uy&addressdetails=0',
    );
    // Sin User-Agent custom: en web el navegador lo agrega y un header
    // forbidden dispara CORS preflight que algunos servidores rechazan.
    final response = await _http.get(uri);
    if (response.statusCode != 200) return const [];
    final raw = jsonDecode(response.body) as List<dynamic>;
    return raw.map((r) {
      final m = r as Map<String, dynamic>;
      return SugerenciaLugar(
        etiqueta: m['display_name'] as String,
        ubicacion: Ubicacion(
          latitud: double.parse(m['lat'] as String),
          longitud: double.parse(m['lon'] as String),
          timestamp: DateTime.now(),
        ),
      );
    }).toList();
  }
}
