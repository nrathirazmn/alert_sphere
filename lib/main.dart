import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/incident_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => IncidentProvider()),
      ],
      child: const AlertSphereApp(),
    ),
  );
}

class AlertSphereApp extends StatelessWidget {
  const AlertSphereApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlertSphere',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        primaryColor: const Color(0xFFFF6B35),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B35),
          secondary: const Color(0xFFE63946),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8F0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF6B35),
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // cardTheme: CardTheme(
        //   elevation: 4,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(16),
        //   ),
        // ),
      ),
      home: const SplashScreen(),
    );
  }
}