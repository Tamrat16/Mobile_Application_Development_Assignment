import 'package:flutter/material.dart';
import 'services/pin_service.dart';
import 'services/preferences_service.dart';
import 'screens/pin_setup_screen.dart';
import 'screens/pin_verify_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/add_edit_expense_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hasPin = await PinService().hasPin();
  final prefs = PreferencesService();
  final isDark = await prefs.isDarkMode();
  runApp(MyApp(hasPin: hasPin, initialDarkMode: isDark));
}

class MyApp extends StatelessWidget {
  final bool hasPin;
  final bool initialDarkMode;

  const MyApp({super.key, required this.hasPin, required this.initialDarkMode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyMoney Tracker',
      debugShowCheckedModeBanner: false,
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      themeMode: initialDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: hasPin ? '/pinVerify' : '/pinSetup',
      routes: {
        '/pinSetup': (_) => const PinSetupScreen(),
        '/pinVerify': (_) => const PinVerifyScreen(),
        '/home': (_) => const HomeScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/addEditExpense': (_) => const AddEditExpenseScreen(),
      },
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF00897B), // Teal
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF00897B),
        secondary: Color(0xFFFFB300), // Amber
        surface: Colors.white,
        background: Color(0xFFF5F5F5),
      ),
      fontFamily: 'Poppins', // or remove if not installed
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFF00897B),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: Colors.white),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00897B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF00897B),
        foregroundColor: Colors.white,
      ),
    );
  }ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF00897B),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00897B),
        secondary: Color(0xFFFFB300),
        surface: Color(0xFF1E1E2E),
        background: Color(0xFF121212),
      ),
      fontFamily: 'Poppins',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFF00897B),
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.grey.shade800.withOpacity(0.3),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00897B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }
}