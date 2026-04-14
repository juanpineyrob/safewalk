import '../models/notificacion.dart';
import '../models/ubicacion.dart';
import '../models/zona_peligrosa.dart';

class NotificacionService {
  double radioAlerta = 500; // metros

  void verificarProximidadUsuario(
    Ubicacion ubicacion,
    List<ZonaPeligrosa> zonas,
  ) {
    // TODO: Verificar proximidad y generar alertas locales
  }

  Future<void> enviarNotificacionLocal(Notificacion notificacion) async {
    // TODO: Notificación local con flutter_local_notifications
  }
}
