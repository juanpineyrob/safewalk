import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  // Override desde CLI:
  //   flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8080
  // Por defecto:
  //   Web/iOS/desktop → localhost:8080
  //   Android emulator → 10.0.2.2:8080 (alias del host)
  static const String _override =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }
}
