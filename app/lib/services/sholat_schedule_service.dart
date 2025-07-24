import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SholatSchedule {
  final String subuh;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;
  final String date;

  SholatSchedule({
    required this.subuh,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
    required this.date,
  });

  factory SholatSchedule.fromAladhanJson(Map<String, dynamic> json) {
    final timings = json['data']['timings'];
    final date = json['data']['date']['readable'];
    return SholatSchedule(
      subuh: timings['Fajr'] ?? '-',
      dzuhur: timings['Dhuhr'] ?? '-',
      ashar: timings['Asr'] ?? '-',
      maghrib: timings['Maghrib'] ?? '-',
      isya: timings['Isha'] ?? '-',
      date: date,
    );
  }

  Map<String, dynamic> toJson() => {
    'subuh': subuh,
    'dzuhur': dzuhur,
    'ashar': ashar,
    'maghrib': maghrib,
    'isya': isya,
    'date': date,
  };

  factory SholatSchedule.fromJson(Map<String, dynamic> json) {
    return SholatSchedule(
      subuh: json['subuh'],
      dzuhur: json['dzuhur'],
      ashar: json['ashar'],
      maghrib: json['maghrib'],
      isya: json['isya'],
      date: json['date'],
    );
  }
}

class SholatScheduleService {
  static const int _cacheExpirationHours = 12;
  static const String _cacheKey = 'sholat_schedule_cache';
  
  /// Mengambil jadwal sholat berdasarkan lokasi (latitude dan longitude)
  static Future<SholatSchedule?> fetchFromLocation({
    required double latitude,
    required double longitude,
    int method = 5, // default: University of Islamic Sciences, Karachi
  }) async {
    try {
      // Check cache first
      final cachedSchedule = await _getCachedSchedule(latitude, longitude);
      if (cachedSchedule != null) {
        return cachedSchedule;
      }

      final url = Uri.parse(
        'https://api.aladhan.com/v1/timings?latitude=$latitude&longitude=$longitude&method=$method',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final schedule = SholatSchedule.fromAladhanJson(data);
        
        // Cache the result
        await _cacheSchedule(latitude, longitude, schedule);
        
        return schedule;
      } else {
        throw Exception('Failed to load prayer times: ${response.statusCode}');
      }
    } catch (e) {
      // Try to get cached data even if it's expired in case of error
      final cachedSchedule = await _getCachedSchedule(latitude, longitude, ignoreExpiration: true);
      if (cachedSchedule != null) {
        return cachedSchedule;
      }
      throw Exception('Error fetching prayer times: $e');
    }
  }

  static Future<SholatSchedule?> _getCachedSchedule(
    double latitude,
    double longitude, {
    bool ignoreExpiration = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString(_getCacheKey(latitude, longitude));
      
      if (cacheJson == null) return null;
      
      final cache = json.decode(cacheJson);
      final timestamp = DateTime.fromMillisecondsSinceEpoch(cache['timestamp']);
      
      // Check if cache is expired
      if (!ignoreExpiration) {
        final now = DateTime.now();
        final difference = now.difference(timestamp);
        if (difference.inHours >= _cacheExpirationHours) {
          return null;
        }
      }
      
      return SholatSchedule.fromJson(cache['data']);
    } catch (e) {
      return null;
    }
  }

  static Future<void> _cacheSchedule(
    double latitude,
    double longitude,
    SholatSchedule schedule,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cache = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': schedule.toJson(),
      };
      await prefs.setString(_getCacheKey(latitude, longitude), json.encode(cache));
    } catch (e) {
      // Ignore cache errors
    }
  }

  static String _getCacheKey(double latitude, double longitude) {
    return '${_cacheKey}_${latitude.toStringAsFixed(4)}_${longitude.toStringAsFixed(4)}';
  }
}
