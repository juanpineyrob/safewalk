import 'package:postgres/postgres.dart';

class ZonaRecord {
  final String id;
  final String nombre;
  final String? descripcion;
  final String categoria;
  final double lat;
  final double lon;
  final int radioMetros;
  final String? reportadaPor;
  final DateTime fechaReporte;

  ZonaRecord({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.lat,
    required this.lon,
    required this.radioMetros,
    required this.reportadaPor,
    required this.fechaReporte,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'categoria': categoria,
        'lat': lat,
        'lon': lon,
        'radioMetros': radioMetros,
        'reportadaPor': reportadaPor,
        'fechaReporte': fechaReporte.toIso8601String(),
      };
}

class ZonaRepository {
  ZonaRepository(this._connection);

  final Connection _connection;

  Future<List<ZonaRecord>> listar() async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT id, nombre, descripcion, categoria, lat, lon, radio_m,
               reportada_por, fecha_reporte
        FROM zonas_peligrosas
        ORDER BY fecha_reporte DESC
      '''),
    );
    return result.map(_mapRow).toList();
  }

  Future<ZonaRecord> crear({
    required String nombre,
    String? descripcion,
    required String categoria,
    required double lat,
    required double lon,
    required int radioMetros,
    String? reportadaPorId,
  }) async {
    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO zonas_peligrosas
          (nombre, descripcion, categoria, lat, lon, radio_m, reportada_por)
        VALUES
          (@nombre, @descripcion, @categoria, @lat, @lon, @radio_m,
           @reportada_por::uuid)
        RETURNING id, nombre, descripcion, categoria, lat, lon, radio_m,
                  reportada_por, fecha_reporte
      '''),
      parameters: {
        'nombre': nombre,
        'descripcion': descripcion,
        'categoria': categoria,
        'lat': lat,
        'lon': lon,
        'radio_m': radioMetros,
        'reportada_por': reportadaPorId,
      },
    );
    return _mapRow(result.first);
  }

  ZonaRecord _mapRow(ResultRow row) {
    final map = row.toColumnMap();
    return ZonaRecord(
      id: map['id'].toString(),
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String?,
      categoria: map['categoria'] as String,
      lat: (map['lat'] as num).toDouble(),
      lon: (map['lon'] as num).toDouble(),
      radioMetros: (map['radio_m'] as num).toInt(),
      reportadaPor: map['reportada_por']?.toString(),
      fechaReporte: map['fecha_reporte'] as DateTime,
    );
  }
}
