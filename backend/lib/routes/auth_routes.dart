import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../env.dart';
import '../middleware/auth_middleware.dart';
import '../repositories/usuario_repository.dart';

class AuthRoutes {
  AuthRoutes(this._usuarios);

  final UsuarioRepository _usuarios;

  Router get router {
    final router = Router();

    router.post('/register', _register);
    router.post('/login', _login);
    router.get(
      '/me',
      const Pipeline().addMiddleware(requireAuth()).addHandler(_me),
    );

    return router;
  }

  Future<Response> _register(Request request) async {
    final body = await _readJson(request);
    if (body == null) return _badRequest('JSON inválido');

    final nombre = (body['nombre'] as String?)?.trim();
    final email = (body['email'] as String?)?.trim().toLowerCase();
    final password = body['password'] as String?;

    if (nombre == null || nombre.isEmpty) {
      return _badRequest('nombre requerido');
    }
    if (email == null || !email.contains('@')) {
      return _badRequest('email inválido');
    }
    if (password == null || password.length < 6) {
      return _badRequest('password debe tener al menos 6 caracteres');
    }

    final hash = BCrypt.hashpw(password, BCrypt.gensalt(logRounds: 10));

    try {
      final usuario = await _usuarios.crear(
        nombre: nombre,
        email: email,
        passwordHash: hash,
      );
      final token = _firmarToken(usuario.id);
      return _json(201, {
        'usuario': usuario.toPublicJson(),
        'token': token,
      });
    } on EmailDuplicadoException {
      return _json(409, {'error': 'El email ya está registrado'});
    }
  }

  Future<Response> _login(Request request) async {
    final body = await _readJson(request);
    if (body == null) return _badRequest('JSON inválido');

    final email = (body['email'] as String?)?.trim().toLowerCase();
    final password = body['password'] as String?;

    if (email == null || password == null) {
      return _badRequest('email y password requeridos');
    }

    final usuario = await _usuarios.buscarPorEmail(email);
    if (usuario == null) {
      return _json(401, {'error': 'Credenciales inválidas'});
    }
    final ok = BCrypt.checkpw(password, usuario.passwordHash);
    if (!ok) {
      return _json(401, {'error': 'Credenciales inválidas'});
    }
    final token = _firmarToken(usuario.id);
    return _json(200, {
      'usuario': usuario.toPublicJson(),
      'token': token,
    });
  }

  Future<Response> _me(Request request) async {
    final id = userIdFrom(request);
    if (id == null) {
      return _json(401, {'error': 'No autenticado'});
    }
    final usuario = await _usuarios.buscarPorId(id);
    if (usuario == null) {
      return _json(404, {'error': 'Usuario no encontrado'});
    }
    return _json(200, {'usuario': usuario.toPublicJson()});
  }

  String _firmarToken(String usuarioId) {
    final jwt = JWT(
      {'sub': usuarioId},
      subject: usuarioId,
    );
    return jwt.sign(
      SecretKey(Env.jwtSecret),
      expiresIn: const Duration(days: 7),
    );
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
