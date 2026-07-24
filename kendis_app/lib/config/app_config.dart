import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  AppConfig._();

  /// Urutan URL yang akan dicoba otomatis. Pertama yang berhasil di-cache.
  static const List<String> candidateUrls = [
    'http://localhost/kendis-plnnp/kendis_api',
    'http://10.0.2.2/kendis-plnnp/kendis_api',
    'https://sharie-untuberculous-devona.ngrok-free.dev/kendis-plnnp/kendis_api',
  ];

  static const String _cacheKey = 'cached_base_url';
  static String _cachedUrl = '';

  /// URL yang sedang aktif (cache > default platform).
  static String get baseUrl => _cachedUrl.isNotEmpty ? _cachedUrl : _defaultUrl;

  static String get _defaultUrl {
    if (kIsWeb) return candidateUrls[0];
    return candidateUrls[1];
  }

  /// Muat URL tersimpan dari SharedPreferences.
  static Future<void> loadCachedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedUrl = prefs.getString(_cacheKey) ?? '';
  }

  /// Simpan URL yang berhasil terkoneksi.
  static Future<void> cacheUrl(String url) async {
    if (url == _cachedUrl) return;
    _cachedUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, url);
  }
}
