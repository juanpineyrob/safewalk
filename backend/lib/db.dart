import 'package:postgres/postgres.dart';

import 'env.dart';

class Db {
  Db._(this._connection);

  final Connection _connection;

  Connection get connection => _connection;

  static Future<Db> connect() async {
    final connection = await Connection.open(
      Endpoint(
        host: Env.postgresHost,
        port: Env.postgresPort,
        database: Env.postgresDb,
        username: Env.postgresUser,
        password: Env.postgresPassword,
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
    return Db._(connection);
  }

  Future<void> close() => _connection.close();
}
