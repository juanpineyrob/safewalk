import 'ubicacion.dart';
import 'usuario.dart';

class Caminata {
  final String id;
  final Usuario usuario;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final double distancia;
  final Duration duracion;
  final List<Ubicacion> recorrido;
  final bool activa;

  const Caminata({
    required this.id,
    required this.usuario,
    required this.fechaInicio,
    this.fechaFin,
    this.distancia = 0,
    this.duracion = Duration.zero,
    this.recorrido = const [],
    this.activa = false,
  });
}
