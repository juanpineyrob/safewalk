import 'tipo_cuenta.dart';

class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String? fotoPerfil;
  final TipoCuenta tipoCuenta;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.fotoPerfil,
    this.tipoCuenta = TipoCuenta.gratuita,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'] as String,
        nombre: json['nombre'] as String,
        email: json['email'] as String,
        fotoPerfil: json['fotoPerfil'] as String?,
        tipoCuenta: _parseTipoCuenta(json['tipoCuenta'] as String?),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'email': email,
        'fotoPerfil': fotoPerfil,
        'tipoCuenta': tipoCuenta.name,
      };

  static TipoCuenta _parseTipoCuenta(String? raw) {
    return TipoCuenta.values.firstWhere(
      (t) => t.name == raw,
      orElse: () => TipoCuenta.gratuita,
    );
  }
}
