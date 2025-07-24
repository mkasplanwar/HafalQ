import 'dart:convert';
import 'package:flutter/services.dart';

class SurahService {
  static Future<List<dynamic>> loadSurahData() async {
    final String response =
        await rootBundle.loadString('assets/surah.json');
    final List<dynamic> data = json.decode(response);
    return data;
  }
}
