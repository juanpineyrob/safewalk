import 'dart:io';

class Env {
  Env._();

  static String require(String key) {
    final value = Platform.environment[key];
    if (value == null || value.isEmpty) {
      throw StateError('Falta la variable de entorno $key');
    }
    return value;
  }

  static String optional(String key, String fallback) =>
      Platform.environment[key] ?? fallback;

  static String get postgresHost => optional('POSTGRES_HOST', 'postgres');
  static int get postgresPort =>
      int.parse(optional('POSTGRES_PORT', '5432'));
  static String get postgresDb => require('POSTGRES_DB');
  static String get postgresUser => require('POSTGRES_USER');
  static String get postgresPassword => require('POSTGRES_PASSWORD');
  static String get jwtSecret => require('JWT_SECRET');
  static int get serverPort => int.parse(optional('PORT', '8080'));
}
