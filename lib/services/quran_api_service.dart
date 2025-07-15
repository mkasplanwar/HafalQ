import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah.dart';
import '../models/ayat.dart';

class QuranApiService {
  static const String baseUrl = 'https://api.quran.gading.dev/surah';

  Future<List<Surah>> fetchSurahList() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List surahList = data['data'];
      return surahList.map((json) => Surah.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load surah');
    }
  }

  // Fetch detail ayat surah dari api.quran.gading.dev
  Future<List<Ayat>> fetchAyatList(int surahNumber) async {
    final url = '$baseUrl/$surahNumber';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List ayatList = data['data']['verses'];
      return ayatList.map((json) => Ayat.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load ayat: ${response.statusCode}');
    }
  }
}
