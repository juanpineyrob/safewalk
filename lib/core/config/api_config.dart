import 'dart:io';

class ApiConfig {
  ApiConfig._();

  // En el emulador de Android, 10.0.2.2 mapea al localhost del host.
  // En iOS simulator y desktop, localhost funciona directo.
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }
}
