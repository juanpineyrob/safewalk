import 'package:flutter/foundation.dart';

import '../models/notificacion.dart';

class NotificacionViewModel extends ChangeNotifier {
  final List<Notificacion> _notificaciones = [];

  List<Notificacion> get notificaciones => _notificaciones;
  int get noLeidas =>
      _notificaciones.where((n) => !n.leida).length;

  void agregar(Notificacion notificacion) {
    _notificaciones.insert(0, notificacion);
    notifyListeners();
  }

  void marcarComoLeida(String id) {
    // TODO: Implementar marcado como leída
    notifyListeners();
  }
}
