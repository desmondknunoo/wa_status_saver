import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/status_provider.dart';
import 'providers/settings_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StatusProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const StatusSaverApp(),
    ),
  );
}

class StatusSaverApp extends StatelessWidget {
  const StatusSaverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        // Set system UI overlay style based on theme
        final isDarkMode =
            settings.themeMode == ThemeMode.dark ||
            (settings.themeMode == ThemeMode.system &&
                MediaQuery.platformBrightnessOf(context) == Brightness.dark);

        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDarkMode
                ? Brightness.light
                : Brightness.dark,
            systemNavigationBarColor: isDarkMode
                ? const Color(0xFF1A1A1A)
                : Colors.white,
            systemNavigationBarIconBrightness: isDarkMode
                ? Brightness.light
                : Brightness.dark,
          ),
        );

        return MaterialApp(
          title: 'Status Saver',
          debugShowCheckedModeBanner: false,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: settings.themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF25D366),
        brightness: Brightness.light,
        primary: const Color(0xFF075E54),
        secondary: const Color(0xFF25D366),
      ),
      scaffoldBackgroundColor: const Color(0xFFF0F2F5),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF075E54),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF075E54),
        unselectedItemColor: Colors.grey,
      ),
      fontFamily: 'Roboto',
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF25D366),
        brightness: Brightness.dark,
        surface: const Color(0xFF121212),
        primary: const Color(0xFF25D366),
      ),
      scaffoldBackgroundColor: const Color(0xFF0D0D0D),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: const CardThemeData(color: Color(0xFF1E1E1E), elevation: 0),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A1A1A),
        selectedItemColor: Color(0xFF25D366),
        unselectedItemColor: Colors.grey,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF25D366),
        foregroundColor: Colors.white,
      ),
      fontFamily: 'Roboto',
    );
  }
}
