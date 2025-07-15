import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/surah.dart';
import '../models/ayat.dart';

class QuranApiService {
  static const String baseUrl = 'https://api.quran.gading.dev/surah';
  static const String fallbackUrl = 'https://api.alquran.cloud/v1/surah';
  static const int _maxRetries = 3;
  static const Duration _timeout = Duration(seconds: 10);
  
  static const String _surahListCacheKey = 'quran_surah_list_cache';
  static const String _ayatCacheKeyPrefix = 'quran_ayat_cache_';
  static const Duration _cacheDuration = Duration(days: 30); // Cache for 30 days

  Future<List<Surah>> fetchSurahList() async {
    try {
      // Check cache first
      final cachedData = await _getCachedData(_surahListCacheKey);
      if (cachedData != null) {
        final List surahList = json.decode(cachedData);
        return surahList.map((json) => Surah.fromJson(json)).toList();
      }

      // Try primary API
      try {
        final response = await _fetchWithRetry(baseUrl);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List surahList = data['data'];
          
          // Cache the result
          await _cacheData(_surahListCacheKey, json.encode(surahList));
          
          return surahList.map((json) => Surah.fromJson(json)).toList();
        }
      } catch (e) {
        print('Primary API failed: $e');
      }

      // Try fallback API if primary fails
      final response = await _fetchWithRetry(fallbackUrl);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List surahList = data['data'];
        
        // Cache the result
        await _cacheData(_surahListCacheKey, json.encode(surahList));
        
        return surahList.map((json) => Surah.fromJson(json)).toList();
      }

      throw Exception('Failed to load surah list from all sources');
    } catch (e) {
      // Try to get from cache even if expired
      final cachedData = await _getCachedData(_surahListCacheKey, ignoreExpiration: true);
      if (cachedData != null) {
        final List surahList = json.decode(cachedData);
        return surahList.map((json) => Surah.fromJson(json)).toList();
      }
      throw Exception('Failed to load surah list: $e');
    }
  }

  Future<List<Ayat>> fetchAyatList(int surahNumber) async {
    final cacheKey = '$_ayatCacheKeyPrefix$surahNumber';
    
    try {
      // Check cache first
      final cachedData = await _getCachedData(cacheKey);
      if (cachedData != null) {
        final List ayatList = json.decode(cachedData);
        return ayatList.map((json) => Ayat.fromJson(json)).toList();
      }

      // Try primary API
      try {
        final url = '$baseUrl/$surahNumber';
        final response = await _fetchWithRetry(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List ayatList = data['data']['verses'];
          
          // Cache the result
          await _cacheData(cacheKey, json.encode(ayatList));
          
          return ayatList.map((json) => Ayat.fromJson(json)).toList();
        }
      } catch (e) {
        print('Primary API failed: $e');
      }

      // Try fallback API
      final fallbackUrl = '${QuranApiService.fallbackUrl}/$surahNumber';
      final response = await _fetchWithRetry(fallbackUrl);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List ayatList = data['data']['ayahs'];
        
        // Cache the result
        await _cacheData(cacheKey, json.encode(ayatList));
        
        return ayatList.map((json) => Ayat.fromJson(json)).toList();
      }

      throw Exception('Failed to load ayat from all sources');
    } catch (e) {
      // Try to get from cache even if expired
      final cachedData = await _getCachedData(cacheKey, ignoreExpiration: true);
      if (cachedData != null) {
        final List ayatList = json.decode(cachedData);
        return ayatList.map((json) => Ayat.fromJson(json)).toList();
      }
      throw Exception('Failed to load ayat: $e');
    }
  }

  Future<http.Response> _fetchWithRetry(String url, {int retryCount = 0}) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      return response;
    } catch (e) {
      if (retryCount < _maxRetries) {
        // Exponential backoff: wait 2^retryCount seconds before retrying
        await Future.delayed(Duration(seconds: 1 << retryCount));
        return _fetchWithRetry(url, retryCount: retryCount + 1);
      }
      rethrow;
    }
  }

  Future<String?> _getCachedData(String key, {bool ignoreExpiration = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString(key);
      
      if (cacheJson == null) return null;
      
      final cache = json.decode(cacheJson);
      final timestamp = DateTime.fromMillisecondsSinceEpoch(cache['timestamp']);
      
      if (!ignoreExpiration) {
        final now = DateTime.now();
        if (now.difference(timestamp) > _cacheDuration) {
          return null;
        }
      }
      
      return cache['data'];
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheData(String key, String data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cache = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': data,
      };
      await prefs.setString(key, json.encode(cache));
    } catch (e) {
      // Ignore cache errors
    }
  }
}
