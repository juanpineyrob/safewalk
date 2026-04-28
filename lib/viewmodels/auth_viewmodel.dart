import 'package:flutter/foundation.dart';

import '../models/usuario.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  Usuario? _usuario;
  bool _cargando = false;
  String? _error;

  Usuario? get usuario => _usuario;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get autenticado => _usuario != null;

  Future<void> restaurarSesion() async {
    _cargando = true;
    notifyListeners();
    try {
      _usuario = await _authService.obtenerSesionPersistida();
    } catch (_) {
      _usuario = null;
    }
    _cargando = false;
    notifyListeners();
  }

  Future<bool> iniciarSesion(String email, String password) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _usuario = await _authService.iniciarSesion(email, password);
      _cargando = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.statusCode == 401
          ? 'Email o contraseña incorrectos'
          : e.mensaje;
      _cargando = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'No se pudo iniciar sesión. Verifica tu conexión.';
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
      return true;
    } on ApiException catch (e) {
      _error = e.statusCode == 409
          ? 'El email ya está registrado'
          : e.mensaje;
      _cargando = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'No se pudo registrar. Verifica tu conexión.';
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
