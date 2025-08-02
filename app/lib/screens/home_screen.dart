import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> allSurah = [];
  List<dynamic> filteredSurah = [];

  @override
  void initState() {
    super.initState();
    loadSurahData();
  }

  // Load data surah dari assets JSON
  Future<void> loadSurahData() async {
    final String response = await rootBundle.loadString('assets/surah.json');
    final List<dynamic> data = json.decode(response);

    setState(() {
      allSurah = data;
      filteredSurah = data;
    });
  }

  // Pencarian surah
  void _searchSurah(String query) {
    setState(() {
      filteredSurah = allSurah.where((surah) {
        final name = surah['name'].toString().toLowerCase();
        final arabic = surah['arabic'].toString().toLowerCase();
        return name.contains(query.toLowerCase()) ||
            arabic.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg_hafalq.png'), // Background gambar
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Search dan logo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: _searchSurah,
                        style: const TextStyle(fontFamily: 'Nunito'),
                        decoration: InputDecoration(
                          hintText: 'Cari surah...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/logo_hafalq.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Judul Surah
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Surah',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Daftar Surah
              Expanded(
                child: filteredSurah.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredSurah.length,
                        itemBuilder: (context, index) {
                          final surah = filteredSurah[index];
                          return SurahCard(
                            number: surah['number'],
                            name: surah['name'],
                            arabic: surah['arabic'],
                            place: surah['place'],
                            ayahs: surah['ayahs'],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navbar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontFamily: 'Nunito'),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Nunito'),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Hafalan'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorit'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
      ),
    );
  }
}

// Card untuk menampilkan 1 surah
class SurahCard extends StatelessWidget {
  final int number;
  final String name;
  final String arabic;
  final String place;
  final int ayahs;

  const SurahCard({
    super.key,
    required this.number,
    required this.name,
    required this.arabic,
    required this.place,
    required this.ayahs,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Text(
            number.toString(),
            style: const TextStyle(color: Colors.white, fontFamily: 'Nunito'),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              arabic,
              style: const TextStyle(
                fontFamily: 'QuranFont',
                fontSize: 24,
                color: Colors.teal,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
        subtitle: Text(
          '$place | $ayahs Ayat',
          style: const TextStyle(fontFamily: 'Nunito'),
        ),
        onTap: () {
          // TODO: Navigasi ke detail surah
        },
      ),
    );
  }
}
