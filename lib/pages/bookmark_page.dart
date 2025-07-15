import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bookmark_service.dart';

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
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
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Bookmark',
                style: TextStyle(
                  fontFamily: 'Merriweather',
                  fontSize: 22,
                  color: Color.fromARGB(255, 45, 46, 46),
                )),
            backgroundColor: const Color(0xFF1ABC9C),
          ),
          body: Consumer<BookmarkService>(
            builder: (context, bookmarkService, child) {
              final bookmarks = bookmarkService.bookmarks;
              if (bookmarks.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada bookmark ayat.',
                    style: TextStyle(fontSize: 18, color: Color(0xFF1ABC9C)),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                itemCount: bookmarks.length,
                itemBuilder: (context, index) {
                  final bookmark = bookmarks[index];
                  // Parsing: format bookmark = Surah:Ayat
                  final parts = bookmark.split(':');
                  final surah = parts.isNotEmpty ? parts[0] : '-';
                  final ayat = parts.length > 1 ? parts[1] : '-';
                  return Dismissible(
                    key: Key(bookmark),
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 24),
                      child: const Icon(Icons.delete, color: Colors.white, size: 30),
                    ),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction) {
                      bookmarkService.removeBookmark(bookmark);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bookmark dihapus')),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: const BorderSide(color: Color(0xFF1ABC9C), width: 1.2),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFF7C873),
                          child: Icon(Icons.bookmark, color: Color(0xFF1ABC9C)),
                        ),
                        title: Text(
                          'Surah $surah : Ayat $ayat',
                          style: const TextStyle(
                            fontFamily: 'Cinzel',
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1ABC9C),
                            fontSize: 17,
                          ),
                        ),
                        subtitle: Text(
                          'Klik untuk detail atau geser untuk hapus',
                          style: TextStyle(fontFamily: 'Poppins',color: Colors.grey.shade700, fontSize: 14),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Color(0xFFF44336)),
                          tooltip: 'Hapus Bookmark',
                          onPressed: () {
                            bookmarkService.removeBookmark(bookmark);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Bookmark dihapus')),
                            );
                          },
                        ),
                        onTap: () async {
                          // Tampilkan dialog detail ayat sederhana
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                title: Text('Detail Bookmark', style: const TextStyle(fontFamily: 'Merriweather',color: Color(0xFF1ABC9C), fontWeight: FontWeight.bold)),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Surah: $surah', style: const TextStyle(fontFamily: 'Merriweather',fontWeight: FontWeight.bold)),
                                    Text('Ayat: $ayat', style: const TextStyle(fontFamily: 'Merriweather',fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 12),
                                    Text('Bookmark: $bookmark', style: const TextStyle(fontFamily: 'Merriweather',fontSize: 14, color: Colors.grey)),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('Tutup', style: TextStyle(fontFamily: 'Poppins',color: Color(0xFF1ABC9C))),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
