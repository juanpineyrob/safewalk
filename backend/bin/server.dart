import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'package:safewalk_backend/db.dart';
import 'package:safewalk_backend/env.dart';
import 'package:safewalk_backend/repositories/usuario_repository.dart';
import 'package:safewalk_backend/repositories/zona_repository.dart';
import 'package:safewalk_backend/routes/auth_routes.dart';
import 'package:safewalk_backend/routes/zona_routes.dart';

Future<void> main() async {
  final db = await _connectWithRetry();
  final usuarios = UsuarioRepository(db.connection);
  final zonas = ZonaRepository(db.connection);
  final auth = AuthRoutes(usuarios);
  final zonaRoutes = ZonaRoutes(zonas);

  final root = Router();
  root.get('/healthz', (Request _) => Response.ok('{"status":"ok"}',
      headers: {'content-type': 'application/json'}));
  root.mount('/auth/', auth.router.call);
  root.mount('/zonas', zonaRoutes.router.call);

  final handler = const Pipeline()
      .addMiddleware(_corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(root.call);

  final server = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4,
    Env.serverPort,
  );
  stdout.writeln('SafeWalk backend escuchando en :${server.port}');
}

Future<Db> _connectWithRetry({int intentos = 30}) async {
  Object? ultimaFalla;
  for (var i = 0; i < intentos; i++) {
    try {
      return await Db.connect();
    } catch (e) {
      ultimaFalla = e;
      stdout.writeln('Postgres no disponible (intento ${i + 1}/$intentos): $e');
      await Future.delayed(const Duration(seconds: 2));
    }
  }
  throw StateError('No se pudo conectar a Postgres: $ultimaFalla');
}

Middleware _corsHeaders() {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
  };
  return (innerHandler) {
    return (request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: headers);
      }
      final response = await innerHandler(request);
      return response.change(headers: {...response.headers, ...headers});
    };
  };
}
