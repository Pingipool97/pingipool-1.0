import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const PingipoolApp());
}

class PingipoolApp extends StatelessWidget {
  const PingipoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pingipool 1.0',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'NunitoSans',
        scaffoldBackgroundColor: const Color(0xFF0D0D2B),
        primaryColor: Colors.cyanAccent,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
