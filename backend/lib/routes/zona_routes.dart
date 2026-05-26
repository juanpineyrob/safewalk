import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../middleware/auth_middleware.dart';
import '../repositories/zona_repository.dart';

class ZonaRoutes {
  ZonaRoutes(this._zonas);

  final ZonaRepository _zonas;

  Router get router {
    final router = Router();

    router.get('/', _listar);
    router.post(
      '/',
      const Pipeline().addMiddleware(requireAuth()).addHandler(_crear),
    );

    return router;
  }

  Future<Response> _listar(Request request) async {
    final zonas = await _zonas.listar();
    return _json(200, {
      'zonas': zonas.map((z) => z.toJson()).toList(),
    });
  }

  Future<Response> _crear(Request request) async {
    final body = await _readJson(request);
    if (body == null) return _badRequest('JSON inválido');

    final nombre = (body['nombre'] as String?)?.trim();
    final descripcion = (body['descripcion'] as String?)?.trim();
    final categoria = (body['categoria'] as String?)?.trim() ?? 'general';
    final lat = (body['lat'] as num?)?.toDouble();
    final lon = (body['lon'] as num?)?.toDouble();
    final radio = (body['radioMetros'] as num?)?.toInt() ?? 75;

    if (nombre == null || nombre.isEmpty) {
      return _badRequest('nombre requerido');
    }
    if (lat == null || lat < -90 || lat > 90) {
      return _badRequest('lat inválida');
    }
    if (lon == null || lon < -180 || lon > 180) {
      return _badRequest('lon inválida');
    }
    if (radio <= 0 || radio > 5000) {
      return _badRequest('radioMetros fuera de rango (1-5000)');
    }

    final usuarioId = userIdFrom(request);

    final zona = await _zonas.crear(
      nombre: nombre,
      descripcion: descripcion,
      categoria: categoria.isEmpty ? 'general' : categoria,
      lat: lat,
      lon: lon,
      radioMetros: radio,
      reportadaPorId: usuarioId,
    );
    return _json(201, {'zona': zona.toJson()});
  }

  Future<Map<String, dynamic>?> _readJson(Request request) async {
    try {
      final raw = await request.readAsString();
      if (raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return decoded;
    } catch (_) {
      return null;
    }
  }

  Response _badRequest(String mensaje) => _json(400, {'error': mensaje});

  Response _json(int status, Map<String, dynamic> body) => Response(
        status,
        body: jsonEncode(body),
        headers: {'content-type': 'application/json'},
      );
}
