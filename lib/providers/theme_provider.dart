import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  // Light Theme
  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    dividerColor: Colors.grey,
    hintColor: Colors.grey,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black87),
      headlineMedium: TextStyle(color: Colors.black),
    ),
  );

  // Dark Theme
  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[900],
    cardColor: Colors.grey[850],
    dividerColor: Colors.grey[700],
    hintColor: Colors.grey[400],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.grey[100]),
      bodyMedium: TextStyle(color: Colors.grey[300]),
      headlineMedium: TextStyle(color: Colors.grey[100]),
    ),
  );

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}