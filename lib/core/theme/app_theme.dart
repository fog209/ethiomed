// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFF0D0F1A),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF1A237E),
    onPrimary: Color(0xFFF9A825),
    secondary: Color(0xFFF9A825),
    onSecondary: Color(0xFF1A237E),
    secondaryContainer: Color(0xFF1C2038),
    onSecondaryContainer: Color(0xFFE8EAF6),
    surface: Color(0xFF0D0F1A),
    onSurface: Color(0xFFE8EAF6),
    surfaceContainerHighest: Color(0xFF1C2038),
    onSurfaceVariant: Color(0xFF9FA8DA),
    outline: Color(0xFF252A45),
    error: Color(0xFFB3261E),
    brightness: Brightness.dark,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0D0F1A),
    foregroundColor: Color(0xFFE8EAF6),
    elevation: 0,
    surfaceTintColor: Colors.transparent,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF0A0C16),
    selectedItemColor: Color(0xFFF9A825),
    unselectedItemColor: Color(0xFF4A5080),
  ),
  cardTheme: const CardThemeData(
    color: Color(0xFF151829),
    surfaceTintColor: Colors.transparent,
  ),
  dividerTheme: const DividerThemeData(color: Color(0xFF252A45)),
);
