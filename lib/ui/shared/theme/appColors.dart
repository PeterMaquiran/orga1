import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0B0D10);
  static const surface = Color(0xFF0F2A3D);
  static const primary = Color(0xFF0B5A7A);
  static const secondary = Color(0xFF0B8F7A);
  static const tertiary = Color(0xFF19C37D);
}


final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  colorScheme: const ColorScheme(
    brightness: Brightness.light,

    primary: Colors.black,
    onPrimary: Colors.black,

    secondary: Colors.black,
    onSecondary: Colors.black,

    tertiary: Colors.black,
    onTertiary: Colors.black,

    error: Colors.red,
    onError: Colors.red,

    background: Colors.white,
    onBackground: Colors.white,

    surface: AppColors.surface,
    onSurface: Colors.black,
  ),
);