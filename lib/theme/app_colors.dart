import 'package:flutter/material.dart';

/// Tokens primitivos de color de FinanSmart.
///
/// Estos valores representan la paleta base del sistema de diseño.
/// Los componentes no deberían utilizar estos colores directamente;
/// deben consumir los colores semánticos definidos en AppTheme.
abstract final class AppColors {
  // Azul corporativo
  static const Color blue900 = Color(0xFF0D2F73);
  static const Color blue700 = Color(0xFF1746A2);
  static const Color blue500 = Color(0xFF4169B1);
  static const Color blue100 = Color(0xFFDCE6F8);

  // Neutros
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF7F9FC);
  static const Color gray100 = Color(0xFFF1F3F7);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray600 = Color(0xFF5F6368);
  static const Color gray900 = Color(0xFF202124);

  // Estados
  static const Color green700 = Color(0xFF16713A);
  static const Color green100 = Color(0xFFE6F4EA);

  static const Color red700 = Color(0xFFB3261E);
  static const Color red100 = Color(0xFFF9DEDC);

  static const Color amber800 = Color(0xFF8A4B00);
  static const Color amber100 = Color(0xFFFFEFD1);
}