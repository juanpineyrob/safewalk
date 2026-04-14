import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Paleta principal: blanco y verde (seguridad)
  static const Color verdePrimario = Color(0xFF2E7D32);
  static const Color verdeOscuro = Color(0xFF1B5E20);
  static const Color verdeClaro = Color(0xFF4CAF50);
  static const Color verdeSuave = Color(0xFFE8F5E9);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color grisTexto = Color(0xFF212121);
  static const Color grisSecundario = Color(0xFF757575);
  static const Color grisClaro = Color(0xFFF5F5F5);
  static const Color rojoError = Color(0xFFC62828);

  static ThemeData get tema => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: blanco,
        colorScheme: const ColorScheme.light(
          primary: verdePrimario,
          onPrimary: blanco,
          primaryContainer: verdeSuave,
          onPrimaryContainer: verdeOscuro,
          secondary: verdeClaro,
          onSecondary: blanco,
          surface: blanco,
          onSurface: grisTexto,
          error: rojoError,
          onError: blanco,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: blanco,
          foregroundColor: verdePrimario,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: verdePrimario,
            foregroundColor: blanco,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: verdePrimario,
            minimumSize: const Size(double.infinity, 52),
            side: const BorderSide(color: verdePrimario),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: grisClaro,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: verdePrimario, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: rojoError, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: rojoError, width: 2),
          ),
          labelStyle: const TextStyle(color: grisSecundario),
          floatingLabelStyle: const TextStyle(color: verdePrimario),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: verdePrimario,
            minimumSize: const Size(48, 48),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
}
