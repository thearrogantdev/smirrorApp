import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Define a modern color palette
  static const Color _primaryLight = Color(0xFF6B4EFF); // Vibrant Purple-Blue
  static const Color _primaryDark = Color(0xFF8B75FF);
  static const Color _accent = Color(0xFF00E5FF);

  // Modern card shape used across the app
  static final RoundedRectangleBorder _cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24),
  );

  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryLight,
        brightness: Brightness.light,
        primary: _primaryLight,
        secondary: _accent,
        surface: const Color(0xFFF8F9FA),
        onSurface: const Color(0xFF1E1E24),
        surfaceContainerHighest: const Color(0xFFE9ECEF),
      ),
      useMaterial3: true,
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: _cardShape,
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _primaryLight,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryDark,
        brightness: Brightness.dark,
        primary: _primaryDark,
        secondary: _accent,
        surface: const Color(0xFF16161A),
        // Deep dark background
        onSurface: const Color(0xFFEAEAEA),
        surfaceContainerHighest: const Color(0xFF24262D), // Elevated surface
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF0F0F13), // Almost black
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.outfitTextTheme(
        baseTheme.textTheme,
      ).apply(bodyColor: const Color(0xFFEAEAEA), displayColor: Colors.white),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: _cardShape,
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
        // Using specific container for shadow in dark mode
        backgroundColor: Color(0xFF16161A),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _primaryDark,
        unselectedItemColor: Color(0xFF6B6C75),
        showUnselectedLabels: false,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        iconColor: _primaryDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
