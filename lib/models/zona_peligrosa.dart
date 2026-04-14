import 'ubicacion.dart';
import 'usuario.dart';

class ZonaPeligrosa {
  final String id;
  final String nombre;
  final Ubicacion ubicacion;
  final String descripcion;
  final String categoria;
  final DateTime fechaReporte;
  final Usuario reportadoPor;

  const ZonaPeligrosa({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.descripcion,
    required this.categoria,
    required this.fechaReporte,
    required this.reportadoPor,
  });
}
