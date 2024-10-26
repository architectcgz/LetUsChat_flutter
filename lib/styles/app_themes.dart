import 'package:flutter/material.dart';

class AppThemes {
  static const BottomNavigationBarThemeData commonBottomNavBarTheme =
      BottomNavigationBarThemeData(
    selectedIconTheme: IconThemeData(
      color: Color(0xFF2DC252),
    ),
    selectedLabelStyle: TextStyle(
      color: Color(0xFF2DC252),
    ),
    selectedItemColor: Color(0xFF2DC252),
  );

  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      color: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF7F7F7),
    bottomNavigationBarTheme: commonBottomNavBarTheme.copyWith(
      backgroundColor: const Color(0xFFEAEAEA), // 只覆盖不同的部分
    ),
    // 其他lightTheme的自定义设置
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.grey,
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      color: Colors.black,
    ),
    bottomNavigationBarTheme: commonBottomNavBarTheme,
    // 其他darkTheme的自定义设置
  );

  static final ThemeData greenTheme = ThemeData(
    primarySwatch: Colors.green,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      color: Color(0xFFcde6c7),
    ),
    cardTheme: const CardTheme(
      color: Color(0xFFcde6c7),
    ),
    scaffoldBackgroundColor: Colors.white,
    bottomNavigationBarTheme: commonBottomNavBarTheme,

    // 其他greenTheme的自定义设置
  );

  static final ThemeData brownTheme = ThemeData(
      primaryColor: Colors.brown,
      brightness: Brightness.light,
      appBarTheme: const AppBarTheme(
        color: Color(0xFF905a3d),
      ),
      scaffoldBackgroundColor: const Color(0xFFEBEDF0),
      bottomNavigationBarTheme: commonBottomNavBarTheme);

  static final ThemeData purpleTheme = ThemeData(
      primaryColor: Colors.deepPurpleAccent,
      brightness: Brightness.light,
      appBarTheme: const AppBarTheme(
        color: Color(0xFF6f60aa),
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F7F7),
      bottomNavigationBarTheme: commonBottomNavBarTheme);
}
