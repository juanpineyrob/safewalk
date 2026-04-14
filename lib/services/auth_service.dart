import '../models/usuario.dart';

class AuthService {
  Future<Usuario?> iniciarSesion(String email, String password) async {
    // TODO: Implementar autenticación
    return null;
  }

  Future<Usuario?> registrarse({
    required String nombre,
    required String email,
    required String password,
  }) async {
    // TODO: Implementar registro
    return null;
  }

  Future<void> cerrarSesion() async {
    // TODO: Implementar cierre de sesión
  }
}
