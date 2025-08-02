import 'package:flutter/material.dart';
import '../models/ayat.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/bookmark_service.dart';
import 'package:provider/provider.dart';
import '../pages/bookmark_page.dart';
import '../services/latin_api_service.dart';

class SurahDetailPage extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final String translation;
  final int ayahCount;
  final List<Ayat> ayatList;
  final int? scrollToAyat;

  const SurahDetailPage({
    super.key,
    required this.surahNumber,
    required this.surahName,
    required this.translation,
    required this.ayahCount,
    required this.ayatList,
    this.scrollToAyat,
  });
  
  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  late Future<List<Ayat>> _futureAyatList;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _futureAyatList = _mergeLatin();

    // Tunggu data ayat loaded, baru scroll
    _futureAyatList.then((list) {
      if (widget.scrollToAyat != null) {
        // Delay supaya widget sudah ter-build
        Future.delayed(const Duration(milliseconds: 200), () {
          // Index-nya mulai dari 0, ayat dari 1, jadi kurangi 1
          final targetIndex = (widget.scrollToAyat! - 1).clamp(0, list.length - 1);
          // Scroll ke target index (sesuaikan dengan itemHeight)
          _scrollController.animateTo(
            targetIndex * 125, // itemHeight: 125px kira2 (atur sesuai Card-mu)
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Ayat>> _mergeLatin() async {
    if (widget.ayatList.isNotEmpty && widget.ayatList[0].latin.isNotEmpty) return widget.ayatList;
    try {
      final latinList = await LatinApiService().fetchLatinList(widget.surahNumber);
      return List.generate(widget.ayatList.length, (i) => Ayat(
        number: widget.ayatList[i].number,
        arab: widget.ayatList[i].arab,
        latin: (i < latinList.length && latinList[i].isNotEmpty) ? latinList[i] : '',
        translation: widget.ayatList[i].translation,
        audioUrl: widget.ayatList[i].audioUrl,
      ));
    } catch (e) {
      debugPrint('Gagal fetch latin: $e');
      return widget.ayatList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.surahName, style: const TextStyle(fontFamily: 'Merriweather', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(widget.translation, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Color(0xFFF7C873), fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: const Color(0xFF1ABC9C),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark, color: Color(0xFFF7C873)),
            tooltip: 'Lihat Bookmark',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const BookmarkPage()));
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Ayat>>(
        future: _futureAyatList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Gagal mengambil latin/transliterasi:\n${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final mergedAyatList = snapshot.data ?? widget.ayatList;
          return Column(
            children: [
              SurahAudioPlayer(ayatList: mergedAyatList),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 18),
                  itemCount: mergedAyatList.length,
                  itemBuilder: (context, index) {
                    final ayat = mergedAyatList[index];
                    return _AyatCard(
                      surahNumber: widget.surahNumber,
                      ayat: ayat,
                      surahName: widget.surahName,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SurahAudioPlayer extends StatefulWidget {
  final List<Ayat> ayatList;
  const SurahAudioPlayer({required this.ayatList});

  @override
  State<SurahAudioPlayer> createState() => SurahAudioPlayerState();
}

class SurahAudioPlayerState extends State<SurahAudioPlayer> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isRepeating = false;
  double _speed = 1.0;
  int _currentAyat = 0;
  int _repeatCount = 1;
  int _repeatCounter = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerComplete.listen((event) {
      if (_isRepeating) {
        _repeatCounter++;
        if (_repeatCounter < _repeatCount) {
          _playSurah(startIndex: 0, resetRepeat: false);
        } else {
          setState(() {
            _isPlaying = false;
            _currentAyat = 0;
            _repeatCounter = 0;
          });
        }
      } else if (_currentAyat < widget.ayatList.length - 1) {
        _playSurah(startIndex: _currentAyat + 1);
      } else {
        setState(() {
          _isPlaying = false;
          _currentAyat = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playSurah({int startIndex = 0, bool resetRepeat = true}) async {
    setState(() {
      _isPlaying = true;
      _currentAyat = startIndex;
      if (resetRepeat) _repeatCounter = 0;
    });
    await _audioPlayer.setPlaybackRate(_speed);
    await _audioPlayer.play(UrlSource(widget.ayatList[startIndex].audioUrl));
  }

  void _stopSurah() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _currentAyat = 0;
    });
  }

  void _toggleRepeat() {
    setState(() {
      _isRepeating = !_isRepeating;
    });
  }

  void _setRepeatCount(int? value) {
    if (value != null) {
      setState(() {
        _repeatCount = value;
      });
    }
  }

  void _changeSpeed(double value) {
    setState(() {
      _speed = value;
    });
    _audioPlayer.setPlaybackRate(_speed);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF1ABC9C), width: 2),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        child: Row(
          children: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.stop_circle : Icons.play_circle, color: Color(0xFF1ABC9C), size: 38),
              tooltip: _isPlaying ? 'Stop Surah' : 'Play Surah',
              onPressed: _isPlaying ? _stopSurah : () => _playSurah(),
            ),
            IconButton(
              icon: Icon(_isRepeating ? Icons.repeat_one : Icons.repeat, color: Color(0xFFF7C873), size: 32),
              tooltip: 'Ulangi Surah',
              onPressed: _toggleRepeat,
            ),
            const SizedBox(width: 10),
            if (_isRepeating)
              DropdownButton<int>(
                value: _repeatCount,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('1x')),
                  DropdownMenuItem(value: 5, child: Text('5x')),
                  DropdownMenuItem(value: 10, child: Text('10x')),
                  DropdownMenuItem(value: 15, child: Text('15x')),
                ],
                onChanged: _setRepeatCount,
                style: const TextStyle(color: Color(0xFF1ABC9C), fontWeight: FontWeight.bold),
                dropdownColor: Colors.white,
                underline: Container(height: 2, color: Color(0xFF1ABC9C)),
              ),
            Icon(Icons.speed, color: Color(0xFF1ABC9C), size: 26),
            SizedBox(
              width: 100,
              child: Slider(
                value: _speed,
                min: 0.5,
                max: 2.0,
                divisions: 3,
                label: '${_speed}x',
                activeColor: const Color(0xFF1ABC9C),
                onChanged: _changeSpeed,
              ),
            ),
            const Spacer(),
            if (_isPlaying)
              Flexible(
                child: Text(
                  'Ayat ${_currentAyat + 1}',
                  style: const TextStyle(
                    color: Color(0xFF1ABC9C),
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.graphic_eq, color: Color(0xFFF7C873), size: 28),
          ],
        ),
      ),
    );
  }
}

class _AyatCard extends StatefulWidget {
  final int surahNumber;
  final Ayat ayat;
  final String surahName;
  const _AyatCard({required this.ayat, required this.surahName, required this.surahNumber, Key? key,})
      : super(key: key);

  @override
  State<_AyatCard> createState() => _AyatCardState();
}

class _AyatCardState extends State<_AyatCard> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isRepeating = false;
  double _speed = 1.0;
  int _repeatCount = 1;
  int _repeatCounter = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerComplete.listen((event) {
      if (_isRepeating) {
        _repeatCounter++;
        if (_repeatCounter < _repeatCount) {
          _audioPlayer.play(UrlSource(widget.ayat.audioUrl), position: Duration.zero);
        } else {
          setState(() {
            _isPlaying = false;
            _repeatCounter = 0;
          });
        }
      } else {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _play() async {
    await _audioPlayer.setPlaybackRate(_speed);
    setState(() {
      _isPlaying = true;
      _repeatCounter = 0;
    });
    await _audioPlayer.play(UrlSource(widget.ayat.audioUrl));
  }

  void _stop() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  void _toggleRepeat() {
    setState(() {
      _isRepeating = !_isRepeating;
    });
  }

  void _setRepeatCount(int? value) {
    if (value != null) {
      setState(() {
        _repeatCount = value;
      });
    }
  }

  void _changeSpeed(double value) {
    setState(() {
      _speed = value;
    });
    _audioPlayer.setPlaybackRate(_speed);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xFF1ABC9C), width: 1.1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
      color: isDark ? Colors.teal.withOpacity(0.10) : Colors.white,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFF7C873),
                      child: Text(
                        widget.ayat.number.toString(),
                        style: const TextStyle(fontFamily: 'Poppins', color: Color(0xFF1ABC9C), fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.ayat.arab,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.teal[200]
                                  : const Color.fromARGB(255, 15, 150, 123),
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 5),
                          if (widget.ayat.latin.isNotEmpty)
                            Text(
                              widget.ayat.latin,
                              style: TextStyle(
                                fontFamily: 'Merriweather',
                                fontSize: 14,
                                color: isDark ? Colors.teal[100] : const Color(0xFF1ABC9C),
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.right,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.ayat.translation,
                  style: TextStyle(
                    fontFamily: 'Merriweather',
                    fontSize: 15,
                    color: isDark ? Colors.grey[200] : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                // Kontrol audio per ayat
                Row(
                  children: [
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.stop_circle : Icons.play_circle_fill, color: Color(0xFF1ABC9C), size: 29),
                      tooltip: _isPlaying ? 'Stop' : 'Play',
                      onPressed: _isPlaying ? _stop : _play,
                    ),
                    IconButton(
                      icon: Icon(_isRepeating ? Icons.repeat_one : Icons.repeat, color: Color(0xFFF7C873), size: 24),
                      tooltip: 'Ulangi',
                      onPressed: _toggleRepeat,
                    ),
                    if (_isRepeating)
                      DropdownButton<int>(
                        value: _repeatCount,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1x')),
                          DropdownMenuItem(value: 5, child: Text('5x')),
                          DropdownMenuItem(value: 10, child: Text('10x')),
                        ],
                        onChanged: _setRepeatCount,
                        style: const TextStyle(color: Color(0xFF1ABC9C), fontWeight: FontWeight.bold, fontSize: 13),
                        dropdownColor: Colors.white,
                        underline: SizedBox.shrink(),
                        icon: const Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF1ABC9C)),
                      ),
                    Icon(Icons.speed, color: Color(0xFF1ABC9C), size: 20),
                    SizedBox(
                      width: 62,
                      child: Slider(
                        value: _speed,
                        min: 0.5,
                        max: 2.0,
                        divisions: 3,
                        label: '${_speed}x',
                        activeColor: const Color(0xFF1ABC9C),
                        onChanged: _changeSpeed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // BOOKMARK tombol
          Positioned(
            bottom: 8,
            right: 8,
            child: Consumer<BookmarkService>(
              builder: (context, bookmarkService, child) {
                final bookmarkId = '${widget.surahNumber}:${widget.surahName}:${widget.ayat.number}';
                final isBookmarked = bookmarkService.bookmarks.contains(bookmarkId);
                return IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_add_outlined,
                    color: isBookmarked ? Color(0xFFF7C873) : Color(0xFF1ABC9C),
                    size: 26,
                  ),
                  tooltip: isBookmarked ? 'Hapus Bookmark' : 'Tambah Bookmark',
                  onPressed: () {
                    if (isBookmarked) {
                      bookmarkService.removeBookmark(bookmarkId);
                    } else {
                      bookmarkService.addBookmark(bookmarkId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ditambahkan ke bookmark')),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
