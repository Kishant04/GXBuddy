import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'gx_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: GXColors.bgPrimary,
        colorScheme: const ColorScheme.dark(
          primary: GXColors.violet,
          secondary: GXColors.pink,
          surface: GXColors.bgCard,
          error: GXColors.danger,
          onPrimary: GXColors.textWhite,
          onSecondary: GXColors.textWhite,
          onSurface: GXColors.textWhite,
        ),
        textTheme: AppTypography.textTheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
          ),
          titleTextStyle: TextStyle(
            color: GXColors.textWhite,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: IconThemeData(color: GXColors.textWhite),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.transparent,
          selectedItemColor: GXColors.violet,
          unselectedItemColor: GXColors.textMute,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        dividerColor: GXColors.border,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );
}
