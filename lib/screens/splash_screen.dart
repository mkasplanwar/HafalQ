import 'package:flutter/material.dart';
import '../main.dart'; // jika HomeScreen ada di main.dart

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 7), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // opsional
      body: SizedBox.expand(
        child: Image.asset(
          'assets/splash.gif',
          fit: BoxFit.cover, // agar gambar penuh seluruh layar
        ),
      ),
    );
  }
}
