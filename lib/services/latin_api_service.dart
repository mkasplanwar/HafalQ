import 'dart:convert';
import 'package:http/http.dart' as http;

class LatinApiService {
  static const String npointBaseUrl = 'https://api.npoint.io/99c279bb173a6e28359c/surat';

  String _stripHtmlTags(String htmlText) {
    // Hapus tag HTML sederhana
    final exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return htmlText.replaceAll(exp, '').replaceAll('&nbsp;', ' ').replaceAll('&amp;', '&');
  }

  Future<List<String>> fetchLatinList(int surahNumber) async {
    final url = '$npointBaseUrl/$surahNumber';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        // Struktur: List of ayat, tiap ayat ada 'tr'
        return data.map<String>((json) {
          final val = json['tr'];
          if (val == null) return '';
          return _stripHtmlTags(val.toString());
        }).toList();
      }
    }
    throw Exception('Failed to load latin/transliterasi dari npoint.io');
  }
}
