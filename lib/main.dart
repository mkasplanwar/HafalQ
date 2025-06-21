import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const HafalqApp());
}

class HafalqApp extends StatelessWidget {
  const HafalqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hafalq',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFEAF4FC),
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}
