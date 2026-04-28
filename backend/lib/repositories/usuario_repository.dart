import 'package:postgres/postgres.dart';

class UsuarioRecord {
  final String id;
  final String nombre;
  final String email;
  final String passwordHash;
  final String? fotoPerfil;
  final String tipoCuenta;

  UsuarioRecord({
    required this.id,
    required this.nombre,
    required this.email,
    required this.passwordHash,
    required this.fotoPerfil,
    required this.tipoCuenta,
  });

  Map<String, dynamic> toPublicJson() => {
        'id': id,
        'nombre': nombre,
        'email': email,
        'fotoPerfil': fotoPerfil,
        'tipoCuenta': tipoCuenta,
      };
}

class EmailDuplicadoException implements Exception {}

class UsuarioRepository {
  UsuarioRepository(this._connection);

  final Connection _connection;

  Future<UsuarioRecord> crear({
    required String nombre,
    required String email,
    required String passwordHash,
  }) async {
    try {
      final result = await _connection.execute(
        Sql.named('''
          INSERT INTO usuarios (nombre, email, password_hash)
          VALUES (@nombre, @email, @password_hash)
          RETURNING id, nombre, email, password_hash, foto_perfil, tipo_cuenta
        '''),
        parameters: {
          'nombre': nombre,
          'email': email,
          'password_hash': passwordHash,
        },
      );
      final row = result.first;
      return _mapRow(row);
    } on ServerException catch (e) {
      if (e.code == '23505') {
        throw EmailDuplicadoException();
      }
      rethrow;
    }
  }

  Future<UsuarioRecord?> buscarPorEmail(String email) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT id, nombre, email, password_hash, foto_perfil, tipo_cuenta
        FROM usuarios
        WHERE email = @email
      '''),
      parameters: {'email': email},
    );
    if (result.isEmpty) return null;
    return _mapRow(result.first);
  }

  Future<UsuarioRecord?> buscarPorId(String id) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT id, nombre, email, password_hash, foto_perfil, tipo_cuenta
        FROM usuarios
        WHERE id = @id::uuid
      '''),
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return _mapRow(result.first);
  }

  UsuarioRecord _mapRow(ResultRow row) {
    final map = row.toColumnMap();
    return UsuarioRecord(
      id: map['id'].toString(),
      nombre: map['nombre'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      fotoPerfil: map['foto_perfil'] as String?,
      tipoCuenta: map['tipo_cuenta'] as String,
    );
  }
}
