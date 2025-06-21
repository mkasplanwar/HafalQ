import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const HafalQApp());
}

class HafalQApp extends StatelessWidget {
  const HafalQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HafalQ',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // 👈 panggil splash GIF
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🔹 Background Image - full hingga bawah
        Positioned.fill(
          child: Image.asset(
            'assets/bg_hafalq.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),

        // 🔹 Foreground - Scaffold transparan
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // 🔹 Search & Logo
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'HafalQ',
                            prefixIcon: const Icon(Icons.search),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Image.asset(
                        'assets/logo_hafalq.png',
                        height: 100,
                        width: 100,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 🔹 Jadwal Sholat
                  const Text(
                    'Ashar',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    '15.30',
                    style: TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 15),

                  // 🔹 Banner Quran
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/quran.png',
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🔹 Last Read
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/quran_icon.png',
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          colorBlendMode: BlendMode.srcATop,
                        ),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Al-Fatihah',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Ayat No: 1',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100), // Spacer agar tidak ketabrak FAB
                ],
              ),
            ),
          ),

          // 🔹 FAB besar di tengah
          floatingActionButton: FloatingActionButton.large(
            onPressed: () {},
            backgroundColor: Colors.green,
            shape: const CircleBorder(),
            child: const Icon(Icons.menu_book, color: Colors.white, size: 40),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

          // 🔹 BottomAppBar dengan cekungan besar
          bottomNavigationBar: BottomAppBar(
            color: Colors.white,
            shape: const CircularNotchedRectangle(),
            notchMargin: 16,
            child: SizedBox(
              height: 90,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Kiri
                  SizedBox(
                    height: double.infinity,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.menu, size: 36, color: Colors.green),
                        onPressed: () {},
                      ),
                    ),
                  ),

                  const SizedBox(width: 40), // Spacer untuk FAB

                  // Kanan
                  SizedBox(
                    height: double.infinity,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.bookmark, size: 36, color: Colors.green),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
