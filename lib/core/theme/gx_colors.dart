import 'package:flutter/material.dart';

abstract final class GXColors {
  // Backgrounds
  static const Color bgPrimary = Color(0xFF0C0121);
  static const Color bgSecondary = Color(0xFF050010);
  static const Color bgCard = Color(0xFF130A2E);
  static const Color bgCardHi = Color(0xFF1C1040);

  // Brand
  static const Color violet = Color(0xFF771FFF);
  static const Color violetLight = Color(0xFFA45EFF);
  static const Color violetDeep = Color(0xFF5C12CC);
  static const Color pink = Color(0xFFF8326D);
  static const Color pinkDeep = Color(0xFFC42558);

  // Semantic
  static const Color success = Color(0xFF22C796);
  static const Color successDark = Color(0xFF0F6E56);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerLight = Color(0xFFEF4444);
  static const Color celebration = Color(0xFF7C3AED);
  static const Color celebrationLight = Color(0xFFA855F7);
  static const Color blue = Color(0xFF3B82F6);
  static const Color gold = Color(0xFFFFD66B);

  // Text
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textSoft = Color(0xFFB8B3C7);
  static const Color textMute = Color(0xFF6B6585);

  // Borders
  static const Color border = Color(0x12FFFFFF);
  static const Color borderStrong = Color(0x24FFFFFF);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [violetLight, pink],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1F0A4A), bgPrimary, bgSecondary],
    stops: [0.0, 0.5, 1.0],
  );
}
