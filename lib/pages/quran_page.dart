import 'dart:async';
import 'package:flutter/material.dart';
import '../services/quran_api_service.dart';
import '../models/surah.dart';
import 'surah_detail_page.dart';
import 'package:flutter/services.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  String _searchQuery = '';
  late Future<List<Surah>> _surahListFuture;
  Timer? _debounce;

  // Tambah controller
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _surahListFuture = QuranApiService().fetchSurahList();
    _searchController.addListener(() {
      // Supaya X muncul/hilang ketika user ketik/hapus manual
      setState(() {});
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Qur\'an', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1ABC9C),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar on top, persistent
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama surah atau arti...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1ABC9C)),
                filled: true,
                fillColor: Colors.teal.withOpacity(0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                // IconButton X untuk clear
                suffixIcon: (_searchController.text.isNotEmpty)
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF1ABC9C)),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged(''); // Pastikan list reset
                        },
                        tooltip: 'Hapus pencarian',
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Surah>>(
              future: _surahListFuture,
              builder: (context, snapshot) {
                Widget child;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  child = const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  child = const Center(child: Text('Gagal memuat surah', style: TextStyle(color: Colors.red)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  child = const Center(child: Text('Tidak ada data surah'));
                } else {
                  final surahList = snapshot.data!;
                  final filteredList = _searchQuery.isEmpty
                      ? surahList
                      : surahList
                          .where((s) =>
                              s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                              s.translation.toLowerCase().contains(_searchQuery.toLowerCase()))
                          .toList();
                  if (filteredList.isEmpty) {
                    child = const Center(
                      child: Text('Surah tidak ditemukan', style: TextStyle(color: Color(0xFF1ABC9C), fontSize: 18)),
                    );
                  } else {
                    child = ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredList.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.3, indent: 32, endIndent: 32),
                      itemBuilder: (context, index) {
                        final surah = filteredList[index];
                        return ListTile(
                          onTap: () async {
                            HapticFeedback.selectionClick();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(child: CircularProgressIndicator()),
                            );
                            try {
                              final ayatList = await QuranApiService().fetchAyatList(surah.number);
                              if (mounted) Navigator.pop(context);
                              if (context.mounted) {
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
                              }
                            } catch (e) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal memuat ayat: $e')),
                              );
                            }
                          },
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFF7C873),
                            child: Text(surah.number.toString(), style: const TextStyle(color: Color(0xFF1ABC9C))),
                          ),
                          title: Text(
                            surah.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              fontFamily: 'Cinzel',
                              color: Color(0xFF1ABC9C),
                            ),
                          ),
                          subtitle: Text(
                            surah.translation,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Merriweather',
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[200]
                                  : Colors.black87,
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1ABC9C).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${surah.ayahCount} ayat',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1ABC9C),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                }
                // Pakai AnimatedSwitcher untuk transisi smooth antar state
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: child,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
