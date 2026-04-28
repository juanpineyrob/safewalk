import '../models/usuario.dart';
import 'api_client.dart';

class AuthService {
  AuthService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<Usuario> iniciarSesion(String email, String password) async {
    final response = await _api.post('/auth/login', body: {
      'email': email,
      'password': password,
    });
    await _api.saveToken(response['token'] as String);
    return Usuario.fromJson(response['usuario'] as Map<String, dynamic>);
  }

  Future<Usuario> registrarse({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final response = await _api.post('/auth/register', body: {
      'nombre': nombre,
      'email': email,
      'password': password,
    });
    await _api.saveToken(response['token'] as String);
    return Usuario.fromJson(response['usuario'] as Map<String, dynamic>);
  }

  Future<void> cerrarSesion() => _api.clearToken();

  Future<Usuario?> obtenerSesionPersistida() async {
    final token = await _api.getToken();
    if (token == null) return null;
    try {
      final response = await _api.get('/auth/me');
      return Usuario.fromJson(response['usuario'] as Map<String, dynamic>);
    } on ApiException {
      await _api.clearToken();
      return null;
    } catch (_) {
      return null;
    }
  }
}
