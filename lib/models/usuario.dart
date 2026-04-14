import 'tipo_cuenta.dart';

class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String password;
  final String? fotoPerfil;
  final TipoCuenta tipoCuenta;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.password,
    this.fotoPerfil,
    this.tipoCuenta = TipoCuenta.gratuita,
  });
}
