import 'ubicacion.dart';

class ZonaPeligrosa {
  final String id;
  final String nombre;
  final Ubicacion ubicacion;
  final double radioMetros;
  final String? descripcion;
  final String categoria;
  final DateTime fechaReporte;
  final String? reportadaPorId;

  const ZonaPeligrosa({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.radioMetros,
    required this.categoria,
    required this.fechaReporte,
    this.descripcion,
    this.reportadaPorId,
  });

  factory ZonaPeligrosa.fromJson(Map<String, dynamic> json) {
    final fecha = json['fechaReporte'] as String?;
    return ZonaPeligrosa(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      ubicacion: Ubicacion(
        latitud: (json['lat'] as num).toDouble(),
        longitud: (json['lon'] as num).toDouble(),
        timestamp: fecha != null ? DateTime.parse(fecha) : DateTime.now(),
      ),
      radioMetros: (json['radioMetros'] as num).toDouble(),
      descripcion: json['descripcion'] as String?,
      categoria: json['categoria'] as String? ?? 'general',
      fechaReporte:
          fecha != null ? DateTime.parse(fecha) : DateTime.now(),
      reportadaPorId: json['reportadaPor'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'categoria': categoria,
        'lat': ubicacion.latitud,
        'lon': ubicacion.longitud,
        'radioMetros': radioMetros,
      };
}
