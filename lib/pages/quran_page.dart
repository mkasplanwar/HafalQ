import 'package:flutter/material.dart';
import '../services/quran_api_service.dart';
import '../models/surah.dart';
import 'surah_detail_page.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  String _searchQuery = '';
  late Future<List<Surah>> _surahListFuture;

  @override
  void initState() {
    super.initState();
    _surahListFuture = QuranApiService().fetchSurahList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Surah',style: TextStyle(
        fontFamily: 'Merriweather',
        fontSize: 22,)
        ,),
        backgroundColor: const Color(0xFF1ABC9C),
        actions: [
          IconButton(
            icon: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7C873).withOpacity(0.18),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF7C873).withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.search,
                color: Color(0xFFF7C873),
                size: 34,
                weight: 800,
              ),
            ),
            tooltip: 'Cari Surah',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                isScrollControlled: true,
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      left: 24, right: 24, top: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.search, color: Color(0xFF1ABC9C), size: 28),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Cari nama surah atau arti...',
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(fontSize: 17),
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Color(0xFF1ABC9C)),
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Surah>>(
        future: _surahListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat surah'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada data surah'));
          }
          final surahList = snapshot.data!;
          final filteredList = _searchQuery.isEmpty
              ? surahList
              : surahList.where((s) =>
                  s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  s.translation.toLowerCase().contains(_searchQuery.toLowerCase())
                ).toList();
          if (filteredList.isEmpty) {
            return const Center(child: Text('Surah tidak ditemukan', style: TextStyle(color: Color(0xFF1ABC9C), fontSize: 18)));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final surah = filteredList[index];
              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: Color(0xFF1ABC9C), width: 1.2),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );
                    try {
                      final ayatList = await QuranApiService().fetchAyatList(surah.number);
                      Navigator.pop(context); // tutup dialog loading
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SurahDetailPage(
                            surahNumber: surah.number,
                            surahName: surah.name,
                            translation: surah.translation,
                            ayahCount: surah.ayahCount,
                            ayatList: ayatList,
                          ),
                        ),
                      );
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal memuat ayat: $e')),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFF7C873),
                          child: Text(
                            surah.number.toString(),
                            style: const TextStyle(fontFamily: 'Merriweather',color: Color(0xFF1ABC9C), fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.menu_book_rounded, color: Color(0xFF1ABC9C), size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                surah.name,
                                style: const TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1ABC9C),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                surah.translation,
                                style: const TextStyle(fontFamily: 'Merriweather',fontSize: 15, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1ABC9C).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Ayat: ${surah.ayahCount}',
                            style: const TextStyle(
                              fontFamily: 'Merriweather',
                              fontSize: 14,
                              color: Color(0xFF1ABC9C),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
