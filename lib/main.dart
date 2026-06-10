import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database.dart';
import 'navbar.dart';
import 'features/settings.dart';

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
    final isDarkMode = ref.watch(settingsThemeModeProvider);
    const String designFontFamily = 'Inter';

    TextTheme buildSystemTypography(Color textColor) {
      return const TextTheme(
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          fontFamily: designFontFamily,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          height: 1.4,
          letterSpacing: 0.15,
          fontFamily: designFontFamily,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.3,
          letterSpacing: 0.1,
          fontFamily: designFontFamily,
        ),
        labelMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.6,
          fontFamily: designFontFamily,
        ),
      );
    }

    return MaterialApp(
      title: 'Exomic',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: designFontFamily,
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        textTheme: buildSystemTypography(Colors.black),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: designFontFamily,
        scaffoldBackgroundColor: const Color(0xFF050505),
        textTheme: buildSystemTypography(Colors.white),
      ),
      home: const ExomicNavbarShell(),
    );
  }
}