import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';

import '../env.dart';

const _userIdKey = 'usuarioId';

String? userIdFrom(Request request) =>
    request.context[_userIdKey] as String?;

Middleware requireAuth() {
  return (innerHandler) {
    return (request) async {
      final auth = request.headers['authorization'];
      if (auth == null || !auth.toLowerCase().startsWith('bearer ')) {
        return _unauthorized('Falta header Authorization');
      }
      final token = auth.substring(7).trim();
      try {
        final jwt = JWT.verify(token, SecretKey(Env.jwtSecret));
        final sub = jwt.subject ?? jwt.payload['sub']?.toString();
        if (sub == null) {
          return _unauthorized('Token sin sujeto');
        }
        final updated = request.change(context: {_userIdKey: sub});
        return await innerHandler(updated);
      } on JWTException catch (e) {
        return _unauthorized('Token inválido: ${e.message}');
      }
    };
  };
}

Response _unauthorized(String mensaje) => Response.unauthorized(
      jsonEncode({'error': mensaje}),
      headers: {'content-type': 'application/json'},
    );
