import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/bookmark_service.dart';
import 'services/theme_service.dart';
import 'services/sholat_schedule_service.dart';
import 'services/user_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'pages/quran_page.dart';
import 'pages/bookmark_page.dart';
import 'pages/settings_page.dart';
// Import widget lain jika perlu
import 'widgets/hijri_calendar_card.dart';
import 'widgets/IslamicQuoteCard.dart';
import 'widgets/GreetingHeader.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookmarkService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const HafalQApp(),
    ),
  );
}

class HafalQApp extends StatelessWidget {
  const HafalQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        final themeData = themeService.isDarkMode
            ? ThemeData(
                brightness: Brightness.dark,
                primarySwatch: Colors.teal,
                scaffoldBackgroundColor: const Color(0xFF23272F),
                cardColor: const Color(0xFF31343D),
              )
            : ThemeData(
                brightness: Brightness.light,
                primarySwatch: Colors.teal,
                scaffoldBackgroundColor: Colors.white,
                cardColor: Colors.white,
              );

        return AnimatedTheme(
          data: themeData,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.teal,
              scaffoldBackgroundColor: Colors.white,
              cardColor: Colors.white,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.teal,
              scaffoldBackgroundColor: const Color(0xFF23272F),
              cardColor: const Color(0xFF31343D),
            ),
            themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 1.0;
  bool _imageCached = false;

  @override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (!_imageCached) {
    precacheImage(const AssetImage('assets/bg_hafalq.png'), context);
    _imageCached = true;
  }
}

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 700), () {
      setState(() {
        _opacity = 0.0;
      });
      Future.delayed(const Duration(milliseconds: 400), () {
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
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 700),
        child: const SizedBox.expand(
          child: Image(
            image: AssetImage('assets/splash.png'),
            fit: BoxFit.cover,
          ),
        ),
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

  static const List<Widget> _pages = [
    HomePage(),
    QuranPage(),
    BookmarkPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image (cached)
          const Positioned.fill(
            child: Image(
              image: AssetImage('assets/bg_hafalq.png'),
              fit: BoxFit.cover,
            ),
          ),
          // Lapisan gradasi putih semi-transparan
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(228, 255, 255, 255),
                    Color.fromARGB(255, 255, 255, 255),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Qur'an"),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Bookmark'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
      ),
    );
  }
}
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loadingSholat = true;
  dynamic _sholatSchedule; // Kalau ada model SholatSchedule, bisa pakai tipe itu
  String _sholatError = '';
  String _cityName = '';

  @override
  void initState() {
    super.initState();
    _fetchSholatScheduleWithLocation();
  }

  Future<void> _fetchSholatScheduleWithLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _loadingSholat = false;
            _sholatError = 'Izin lokasi ditolak oleh pengguna';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _loadingSholat = false;
          _sholatError = 'Izin lokasi permanen ditolak. Aktifkan secara manual di pengaturan.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String city = placemarks.isNotEmpty ? placemarks[0].locality ?? '' : '';

      final result = await SholatScheduleService.fetchFromLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      setState(() {
        _sholatSchedule = result;
        _loadingSholat = false;
        _sholatError = result == null ? 'Gagal memuat jadwal sholat' : '';
        _cityName = city;
      });
    } catch (e) {
      setState(() {
        _loadingSholat = false;
        _sholatError = 'Gagal mendapatkan lokasi: $e';
      });
    }
}

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 400;
    final gridAspect = isSmall ? 1.2 : 1.5;
    final username = Provider.of<UserProvider>(context).username;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg_hafalq.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isSmall ? 12 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isSmall ? 5 : 15),
                    GreetingHeader(
                      username: username,
                      city: _cityName,
                      isSmall: isSmall,
                    ),
                    SizedBox(height: isSmall ? 5 : 15),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 17, 124, 103).withOpacity(0.13),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 19, 133, 110).withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(isSmall ? 10 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time, color: const Color.fromARGB(255, 64, 70, 69), size: isSmall ? 16 : 22),
                              SizedBox(width: isSmall ? 5 : 10),
                              Text(
                                "Jadwal Sholat Hari Ini",
                                style: TextStyle(fontFamily: 'Cinzel', color: const Color.fromARGB(255, 67, 72, 71), fontWeight: FontWeight.bold, fontSize: isSmall ? 12 : 16),
                              ),
                            ],
                          ),
                          SizedBox(height: isSmall ? 5 : 10),
                          if (_loadingSholat)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (_sholatSchedule != null)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _SholatTime(label: "Subuh", time: _sholatSchedule!.subuh),
                                  const SizedBox(width: 10),
                                  _SholatTime(label: "Dzuhur", time: _sholatSchedule!.dzuhur),
                                  const SizedBox(width: 10),
                                  _SholatTime(label: "Ashar", time: _sholatSchedule!.ashar),
                                  const SizedBox(width: 10),
                                  _SholatTime(label: "Maghrib", time: _sholatSchedule!.maghrib),
                                  const SizedBox(width: 10),
                                  _SholatTime(label: "Isya", time: _sholatSchedule!.isya),
                                ],
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: Text(_sholatError, style: const TextStyle(color: Colors.red))),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmall ? 10 : 22),
                    SizedBox(
                      height: isSmall ? 44 : 60,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _InfoBanner(
                            icon: Icons.info,
                            text: "Jumat: Perbanyak shalawat dan baca Al Kahfi!",
                            color: const Color.fromRGBO(250, 204, 116, 1),
                            textColor: Colors.white,
                          ),
                          SizedBox(width: isSmall ? 6 : 12),
                          _InfoBanner(
                            icon: Icons.star,
                            text: "Baca Qur'an setiap hari, raih pahala selamanya!",
                            color: const Color.fromRGBO(250, 204, 116, 1),
                            textColor: Colors.white,
                          ),
                          SizedBox(width: isSmall ? 6 : 12),
                          _InfoBanner(
                            icon: Icons.message_sharp,
                            text: "Hafalan itu bukan perlombaan, tapi perjalanan.",
                            color: const Color.fromRGBO(250, 204, 116, 1),
                            textColor: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmall ? 16 : 28),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: isSmall ? 8 : 18,
                      crossAxisSpacing: isSmall ? 8 : 18,
                      childAspectRatio: gridAspect,
                      children: const [
                        _MenuIcon(icon: Icons.menu_book, label: "Al-Qur'an"),
                        _MenuIcon(icon: Icons.headphones, label: "Qari"),
                        _MenuIcon(icon: Icons.memory, label: "Hafalan"),
                        _MenuIcon(icon: Icons.explore, label: "Kiblat"),
                      ],
                    ),
                    SizedBox(height: isSmall ? 60 : 12),
                    const HijriCalendarCard(),
                    const IslamicQuoteCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuIcon extends StatefulWidget {
  final IconData icon;
  final String label;

  const _MenuIcon({
    required this.icon,
    required this.label,
  });

  @override
  State<_MenuIcon> createState() => _MenuIconState();
}

class _MenuIconState extends State<_MenuIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(BuildContext context) {
    switch (widget.label) {
      case "Al-Qur'an":
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) {
              return FadeTransition(
                opacity: animation,
                child: const QuranPage(),
              );
            },
          ),
        );
        break;
      case "Qari":
        // Handle Qari navigation
        break;
      case "Hafalan":
        // Handle Hafalan navigation
        break;
      case "Kiblat":
        // Handle Kiblat navigation
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 400;
    
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        _handleTap(context);
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isPressed 
                  ? Colors.black.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
                blurRadius: _isPressed ? 4 : 8,
                offset: _isPressed 
                  ? const Offset(0, 1)
                  : const Offset(0, 2),
                spreadRadius: _isPressed ? 0 : 1,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'icon_${widget.label}',
                child: Icon(
                  widget.icon,
                  color: const Color(0xFF1ABC9C),
                  size: isSmall ? 28 : 36,
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: isSmall ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: _isPressed 
                    ? const Color(0xFF1ABC9C)
                    : Colors.grey[800],
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatefulWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color textColor;

  const _InfoBanner({
    Key? key,
    required this.icon,
    required this.text,
    required this.color,
    required this.textColor,
  }) : super(key: key);

  @override
  State<_InfoBanner> createState() => _InfoBannerState();
}

class _InfoBannerState extends State<_InfoBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 400;
    
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 12 : 16,
            vertical: isSmall ? 8 : 12,
          ),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_isPressed ? 0.2 : 0.3),
                blurRadius: _isPressed ? 4 : 8,
                offset: _isPressed 
                  ? const Offset(0, 1)
                  : const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 150),
                scale: _isPressed ? 0.9 : 1.0,
                child: Icon(
                  widget.icon,
                  color: widget.textColor,
                  size: isSmall ? 16 : 20,
                ),
              ),
              SizedBox(width: isSmall ? 6 : 8),
              Flexible(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: isSmall ? 11 : 14,
                    fontWeight: FontWeight.w600,
                    color: widget.textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SholatTime extends StatefulWidget {
  final String label;
  final String time;

  const _SholatTime({
    Key? key,
    required this.label,
    required this.time,
  }) : super(key: key);

  @override
  State<_SholatTime> createState() => _SholatTimeState();
}

class _SholatTimeState extends State<_SholatTime> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 400;
    
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 12 : 16,
            vertical: isSmall ? 8 : 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isPressed ? 0.03 : 0.05),
                blurRadius: _isPressed ? 4 : 8,
                offset: _isPressed 
                  ? const Offset(0, 1)
                  : const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: isSmall ? 11 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: isSmall ? 4 : 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: isSmall ? 13 : 16,
                  fontWeight: FontWeight.bold,
                  color: _isPressed 
                    ? const Color(0xFF1ABC9C).withOpacity(0.8)
                    : const Color(0xFF1ABC9C),
                ),
                child: Text(widget.time),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

