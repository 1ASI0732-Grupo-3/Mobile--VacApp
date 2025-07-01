import 'package:flutter/material.dart';

class ColorPalette {
  static const Color primaryColor = Color(0xFF002D26);      // Verde oscuro
  static const Color secondaryColor = Color(0xFFF3F3F3);    // Crema (#f3f3f3)
  static const Color cream = Color(0xFFFFF1BE);             // Crema claro

  static const Color softCream = Color(0xFFFBE7E7);         // Rosa muy pálido (simula fondo suave crema)
  static const Color lightGray = Color(0xFFC0C0C0);         // Gris claro neutro
  static const Color darkGray = Color(0xFF666666);          // Gris oscuro suave
  static const Color shadowGray = Color(0xFFBEBEBE);        // Para bordes o relieves suaves
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color pureBlack = Color(0xFF000000);

  // Transparencias y efectos
  static const Color creamTranslucent = Color.fromRGBO(255, 241, 190, 0.6);
  static const Color greenArrow = Color(0xFFFFF1BE); // flecha clara sobre botón negro
// Colores con transparencia
  static const Color black08 = Color.fromRGBO(0, 0, 0, 0.08);
  static const Color primaryColor40 = Color.fromRGBO(0, 45, 38, 0.4);
}