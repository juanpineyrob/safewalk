import 'package:flutter/foundation.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Usuario? _usuario;
  bool _cargando = false;
  String? _error;

  Usuario? get usuario => _usuario;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get autenticado => _usuario != null;

  Future<bool> iniciarSesion(String email, String password) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _usuario = await _authService.iniciarSesion(email, password);
      _cargando = false;
      notifyListeners();
      return _usuario != null;
    } catch (e) {
      _error = 'Error al iniciar sesión';
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registrarse({
    required String nombre,
    required String email,
    required String password,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _usuario = await _authService.registrarse(
        nombre: nombre,
        email: email,
        password: password,
      );
      _cargando = false;
      notifyListeners();
      return _usuario != null;
    } catch (e) {
      _error = 'Error al registrarse';
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> cerrarSesion() async {
    await _authService.cerrarSesion();
    _usuario = null;
    notifyListeners();
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}
