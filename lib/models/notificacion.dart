import 'tipo_notificacion.dart';

class Notificacion {
  final String id;
  final String titulo;
  final String mensaje;
  final DateTime fecha;
  final bool leida;
  final TipoNotificacion tipo;

  const Notificacion({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.fecha,
    this.leida = false,
    required this.tipo,
  });
}
