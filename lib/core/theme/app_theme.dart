import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Identidad visual SafeWalk
///
/// Concepto: minimalismo refinado. La interfaz cede protagonismo al mapa;
/// las superficies son cálidas, los bordes generosos y las sombras casi
/// invisibles. La tipografía Hanken Grotesk aporta carácter geométrico sin
/// el desgaste de Inter/Roboto.
class AppTheme {
  AppTheme._();

  // Paleta primaria
  static const Color verdePrimario = Color(0xFF0F4D2F);
  static const Color verdeOscuro = Color(0xFF093822);
  static const Color verdeClaro = Color(0xFF2F8A5A);
  static const Color verdeSuave = Color(0xFFE6EFE7);
  static const Color verdeAcento = Color(0xFFC9DBC2);

  // Superficies
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color superficie = Color(0xFFFBFBF8);
  static const Color superficieAlta = Color(0xFFFFFFFF);
  static const Color superficieSuave = Color(0xFFF3F4F0);

  // Texto
  static const Color grisTexto = Color(0xFF0E1813);
  static const Color grisSecundario = Color(0xFF5C665E);
  static const Color grisTerciario = Color(0xFF8B928D);
  static const Color grisClaro = Color(0xFFF1F2EE);

  // Outlines
  static const Color outline = Color(0xFFD8DDD7);
  static const Color outlineSuave = Color(0xFFEBEEE9);

  // Estados
  static const Color rojoError = Color(0xFFB23A48);
  static const Color ambar = Color(0xFFD9A24B);

  /// Sombra multicapa muy sutil — la base del look "Apple-ish".
  static List<BoxShadow> sombraSuave = const [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static List<BoxShadow> sombraFlotante = const [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static TextTheme _textTheme(Color onSurface, Color onSurfaceVariant) {
    final base = GoogleFonts.hankenGroteskTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.8,
        color: onSurface,
        height: 1.05,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
        color: onSurface,
        height: 1.1,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: onSurface,
        height: 1.15,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: onSurface,
        height: 1.2,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        color: onSurface,
        height: 1.25,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: onSurface,
        height: 1.5,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: onSurfaceVariant,
        height: 1.5,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: onSurfaceVariant,
        height: 1.45,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: onSurface,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: onSurfaceVariant,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: onSurfaceVariant,
      ),
    );
  }

  static ThemeData get tema {
    final colorScheme = const ColorScheme.light(
      primary: verdePrimario,
      onPrimary: blanco,
      primaryContainer: verdeSuave,
      onPrimaryContainer: verdeOscuro,
      secondary: verdeClaro,
      onSecondary: blanco,
      secondaryContainer: verdeAcento,
      onSecondaryContainer: verdeOscuro,
      surface: superficie,
      onSurface: grisTexto,
      surfaceContainerHighest: superficieSuave,
      surfaceContainerHigh: superficieAlta,
      surfaceContainer: superficieAlta,
      onSurfaceVariant: grisSecundario,
      outline: outline,
      outlineVariant: outlineSuave,
      error: rojoError,
      onError: blanco,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: superficie,
      textTheme: _textTheme(grisTexto, grisSecundario),
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: superficie,
        surfaceTintColor: Colors.transparent,
        foregroundColor: grisTexto,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.hankenGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: grisTexto,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: superficieAlta,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: verdePrimario,
          foregroundColor: blanco,
          disabledBackgroundColor: outlineSuave,
          disabledForegroundColor: grisTerciario,
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.hankenGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: grisTexto,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.hankenGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: verdePrimario,
          foregroundColor: blanco,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.hankenGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: verdePrimario,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          textStyle: GoogleFonts.hankenGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: superficieSuave,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.hankenGrotesk(
          fontSize: 15,
          color: grisTerciario,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.hankenGrotesk(
          fontSize: 14,
          color: grisSecundario,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: GoogleFonts.hankenGrotesk(
          fontSize: 13,
          color: verdePrimario,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: verdePrimario, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: rojoError, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: rojoError, width: 1.5),
        ),
        errorStyle: GoogleFonts.hankenGrotesk(
          fontSize: 12.5,
          color: rojoError,
          fontWeight: FontWeight.w500,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: blanco,
        foregroundColor: grisTexto,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: CircleBorder(),
        sizeConstraints: BoxConstraints.tightFor(width: 52, height: 52),
      ),
      dividerTheme: const DividerThemeData(
        color: outlineSuave,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: superficieAlta,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: true,
        dragHandleColor: outline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: superficieAlta,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: GoogleFonts.hankenGrotesk(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          color: grisTexto,
          letterSpacing: -0.2,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: grisTexto,
        contentTextStyle: GoogleFonts.hankenGrotesk(
          fontSize: 14,
          color: blanco,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        iconColor: grisTexto,
        titleTextStyle: GoogleFonts.hankenGrotesk(
          fontSize: 15,
          color: grisTexto,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: GoogleFonts.hankenGrotesk(
          fontSize: 13,
          color: grisSecundario,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
