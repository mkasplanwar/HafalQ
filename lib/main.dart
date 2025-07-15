import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/bookmark_service.dart';
import 'pages/quran_page.dart';
import 'pages/bookmark_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _opacity = 0.0;
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              child: Image.asset(
                'assets/splash.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    HomePage(),
    BookmarkPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF1ABC9C),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmark',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BookmarkService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    ),
  );
}
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg_hafalq.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.white.withOpacity(0.82),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ...existing code...
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFFF7C873),
                      child: const Icon(Icons.person, color: Color(0xFF1ABC9C), size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(
                        "Assalamu’alaikum 👋", // versi Arab
                        style: TextStyle(
                          fontFamily: 'Cinzel', // atau font Arab seperti Scheherazade
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal[700],
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Selamat datang di HafalQ!",
                        style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],

                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications, color: Color(0xFF1ABC9C)),
                      onPressed: () {},
                      tooltip: 'Notifikasi',
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                // ...existing code...
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1ABC9C).withOpacity(0.13),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1ABC9C).withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFF1ABC9C).withOpacity(0.18)),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.access_time, color: Color(0xFF1ABC9C)),
                          SizedBox(width: 10),
                          Text("Jadwal Sholat Hari Ini", style: TextStyle(fontFamily: 'Cinzel',color: Color(0xFF1ABC9C), fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          _SholatTime(label: "Subuh", time: "04:30"),
                          _SholatTime(label: "Dzuhur", time: "12:00"),
                          _SholatTime(label: "Ashar", time: "15:30"),
                          _SholatTime(label: "Maghrib", time: "18:00"),
                          _SholatTime(label: "Isya", time: "19:10"),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                // ...existing code...
                SizedBox(
                  height: 60,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _InfoBanner(
                        icon: Icons.info,
                        text: "Jumat: Perbanyak shalawat dan baca Al Kahfi!",
                        color: const Color.fromARGB(255, 250, 204, 116),
                        textColor: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      _InfoBanner(
                        icon: Icons.star,
                        text: "Baca Qur’an setiap hari, raih pahala selamanya!",
                        color: const Color(0xFF1ABC9C),
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                // ...existing code...
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  childAspectRatio: 1.15,
                  children: const [
                    _MenuIcon(icon: Icons.menu_book, label: "Al-Qur’an"),
                    _MenuIcon(icon: Icons.headphones, label: "Qari"),
                    _MenuIcon(icon: Icons.memory, label: "Hafalan"),
                    _MenuIcon(icon: Icons.explore, label: "Kiblat"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Widget Kecil & SettingsPage di bawah ini ---

class _SholatTime extends StatelessWidget {
  final String label;
  final String time;
  const _SholatTime({required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Poppins',color: Color(0xFF1ABC9C), fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1ABC9C).withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(time, style: const TextStyle(fontFamily: 'Poppins',color: Color(0xFF1ABC9C), fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color? textColor;
  const _InfoBanner({required this.icon, required this.text, required this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor ?? const Color(0xFF1ABC9C)),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(fontFamily: 'Poppins',color: textColor ?? const Color(0xFF1ABC9C), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _MenuIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MenuIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (label == "Al-Qur’an") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QuranPage()),
          );
        }
        // TODO: Navigasi menu lain
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1ABC9C),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontFamily: 'Cinzel',color: Color(0xFF1ABC9C), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Halaman Settings
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image sementara di-nonaktifkan untuk diagnosis error isolate/engine
        // Positioned.fill(
        //   child: Image.asset(
        //     'assets/bg_hafalq.webp',
        //     fit: BoxFit.cover,
        //   ),
        // ),
        Container(
          color: Colors.white.withOpacity(0.82),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: const Color(0xFF1ABC9C),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ...existing code...
              // (isi SettingsPage tetap, tidak berubah)
            ],
          ),
        ),
      ],
    );
  }
}
