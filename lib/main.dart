import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database.dart';
import 'navbar.dart';
import 'features/settings.dart';
import 'splash.dart'; // Imported your new splash screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ExomicDatabaseEngine.initializeStorageEngine();

  runApp(
    const ProviderScope(
      child: ExomicAppRoot(),
    ),
  );
}

class ExomicAppRoot extends ConsumerWidget {
  const ExomicAppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the state directly at root level to trigger a structural frame paint instantly
    final isDarkMode = ref.watch(settingsThemeModeProvider);

    const String designFontFamily = 'Inter';

    // Local typography configurations mapping
    TextTheme buildSystemTypography(Color textColor) {
      return TextTheme(
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: designFontFamily, color: textColor),
        bodyLarge: TextStyle(fontSize: 15, height: 1.4, letterSpacing: 0.15, fontFamily: designFontFamily, color: textColor),
        bodyMedium: TextStyle(fontSize: 14, height: 1.3, letterSpacing: 0.1, fontFamily: designFontFamily, color: textColor),
        bodySmall: TextStyle(fontSize: 12, letterSpacing: 0.4, fontFamily: designFontFamily, color: textColor),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.1, fontFamily: designFontFamily, color: textColor),
      );
    }

    return MaterialApp(
      title: 'Exomic Balance Ledger',
      debugShowCheckedModeBanner: false,

      // Explicit Reactive Sync Linking:
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // OPTIMIZED LIGHT SYSTEM THEME SPECIFICATIONS
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: designFontFamily,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        canvasColor: const Color(0xFFFAFAFA),
        cardColor: Colors.white,
        textTheme: buildSystemTypography(Colors.black),

        // Navigation component styling metrics
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFFAFAFA),
          elevation: 0,
          selectedItemColor: Colors.black,
          unselectedItemColor: Color(0xFFB5B5B5),
          type: BottomNavigationBarType.fixed,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFFFAFAFA),
          indicatorColor: Colors.black.withOpacity(0.05),
          labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 11, fontFamily: designFontFamily, fontWeight: FontWeight.bold)),
        ),
      ),

      // OPTIMIZED DARK SYSTEM THEME SPECIFICATIONS
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: designFontFamily,
        scaffoldBackgroundColor: const Color(0xFF050505),
        canvasColor: const Color(0xFF050505),
        cardColor: const Color(0xFF0A0A0A),
        textTheme: buildSystemTypography(Colors.white),

        // Navigation component styling metrics
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF050505),
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Color(0xFF737373),
          type: BottomNavigationBarType.fixed,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF050505),
          indicatorColor: Colors.white.withOpacity(0.05),
          labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 11, fontFamily: designFontFamily, fontWeight: FontWeight.bold)),
        ),
      ),

      // Hooked the app to start with the custom Splash Screen
      home: const SplashScreen(),
    );
  }
}