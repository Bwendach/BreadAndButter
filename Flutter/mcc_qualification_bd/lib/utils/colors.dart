import 'package:flutter/material.dart';

// Light Theme Colors - Warm Bakery Theme
const Color lightPrimary = Color(0xFF8C5E58); // Warm brown
const Color lightSecondary = Color(0xFFB47B84); // Dusty rose
const Color lightAccent = Color(0xFFD4A574); // Warm caramel
const Color lightBackground = Color(0xFFFDEBD0); // Cream
const Color lightSurface = Color(0xFFFFF8F0); // Off white
const Color lightOnPrimary = Colors.white;
const Color lightOnSecondary = Colors.white;
const Color lightOnSurface = Color(0xFF2C1810); // Dark brown
const Color lightOnBackground = Color(0xFF3D2914); // Dark brown
const Color lightCardColor = Color(0xFFFFF5E6); // Light cream
const Color lightDivider = Color(0xFFE8D5C4); // Light brown
const Color lightError = Color(0xFFD32F2F);
const Color lightSuccess = Color(0xFF388E3C);

// Dark Theme Colors - Cozy Evening Bakery
const Color darkPrimary = Color(0xFFB47B84); // Dusty rose (lighter for dark)
const Color darkSecondary = Color(0xFFD4A574); // Warm caramel
const Color darkAccent = Color(0xFF8C5E58); // Warm brown
const Color darkBackground = Color(0xFF1A1A1A); // Dark background
const Color darkSurface = Color(0xFF2D2D2D); // Dark surface
const Color darkOnPrimary = Colors.white;
const Color darkOnSecondary = Colors.black;
const Color darkOnSurface = Color(0xFFE8D5C4); // Light cream text
const Color darkOnBackground = Color(0xFFFDEBD0); // Cream text
const Color darkCardColor = Color(0xFF3D3D3D); // Dark card
const Color darkDivider = Color(0xFF4A4A4A); // Dark divider
const Color darkError = Color(0xFFEF5350);
const Color darkSuccess = Color(0xFF66BB6A);

// Additional Colors
const Color warmOrange = Color(0xFFE17B47);
const Color softYellow = Color(0xFFF5D982);
const Color mutedGreen = Color(0xFF7D8471);
const Color lavenderBlush = Color(0xFFE8D5DA);

// Light Theme
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: lightPrimary,
    secondary: lightSecondary,
    tertiary: lightAccent,
    background: lightBackground,
    surface: lightSurface,
    onPrimary: lightOnPrimary,
    onSecondary: lightOnSecondary,
    onSurface: lightOnSurface,
    onBackground: lightOnBackground,
    error: lightError,
  ),
  scaffoldBackgroundColor: lightBackground,
  cardColor: lightCardColor,
  dividerColor: lightDivider,
  appBarTheme: const AppBarTheme(
    backgroundColor: lightPrimary,
    foregroundColor: lightOnPrimary,
    elevation: 0,
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: lightSecondary,
      foregroundColor: lightOnSecondary,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: lightPrimary),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: lightSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: lightDivider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: lightDivider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: lightPrimary, width: 2),
    ),
  ),
  cardTheme: CardThemeData(
    color: lightCardColor,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: lightSurface,
    selectedItemColor: lightPrimary,
    unselectedItemColor: lightOnSurface,
    type: BottomNavigationBarType.fixed,
  ),
);

// Dark Theme
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: darkPrimary,
    secondary: darkSecondary,
    tertiary: darkAccent,
    background: darkBackground,
    surface: darkSurface,
    onPrimary: darkOnPrimary,
    onSecondary: darkOnSecondary,
    onSurface: darkOnSurface,
    onBackground: darkOnBackground,
    error: darkError,
  ),
  scaffoldBackgroundColor: darkBackground,
  cardColor: darkCardColor,
  dividerColor: darkDivider,
  appBarTheme: const AppBarTheme(
    backgroundColor: darkSurface,
    foregroundColor: darkOnSurface,
    elevation: 0,
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: darkPrimary,
      foregroundColor: darkOnPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: darkPrimary),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: darkSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: darkDivider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: darkDivider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: darkPrimary, width: 2),
    ),
  ),
  cardTheme: CardThemeData(
    color: darkCardColor,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: darkSurface,
    selectedItemColor: darkPrimary,
    unselectedItemColor: darkOnSurface,
    type: BottomNavigationBarType.fixed,
  ),
);

// Legacy colors for backward compatibility
const fontColor = lightOnSurface;
const secondaryColor = lightSecondary;
const accentColor = lightAccent;
const themeColor = lightBackground;
const titleColor = lightPrimary;
