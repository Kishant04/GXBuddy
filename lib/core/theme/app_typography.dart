import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'gx_colors.dart';

abstract final class AppTypography {
  static TextTheme get textTheme => GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32, fontWeight: FontWeight.w800,
            color: GXColors.textWhite, letterSpacing: -0.03,
          ),
          displayMedium: TextStyle(
            fontSize: 26, fontWeight: FontWeight.w800,
            color: GXColors.textWhite, letterSpacing: -0.03,
          ),
          displaySmall: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700,
            color: GXColors.textWhite, letterSpacing: -0.02,
          ),
          headlineMedium: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700,
            color: GXColors.textWhite, letterSpacing: -0.02,
          ),
          titleLarge: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700,
            color: GXColors.textWhite,
          ),
          titleMedium: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600,
            color: GXColors.textWhite,
          ),
          bodyLarge: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w400,
            color: GXColors.textWhite, height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w400,
            color: GXColors.textSoft, height: 1.5,
          ),
          labelLarge: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: GXColors.textWhite, letterSpacing: -0.01,
          ),
          labelSmall: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600,
            color: GXColors.textMute, letterSpacing: 0.1,
          ),
        ),
      );
}
