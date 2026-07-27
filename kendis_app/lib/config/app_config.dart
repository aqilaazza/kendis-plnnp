import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  AppConfig._();

  /// Base URL API
  static const List<String> candidateUrls = [
    // 'https://api.umumcsr.com/kendis'
    'https://sharie-untuberculous-devona.ngrok-free.dev/kendis-plnnp/kendis_api',
  ];

  static const String _cacheKey = 'cached_base_url';
  static String _cachedUrl = '';

  /// URL aktif
  static String get baseUrl =>
      _cachedUrl.isNotEmpty ? _cachedUrl : candidateUrls.first;

  /// Load URL yang pernah disimpan
  static Future<void> loadCachedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedUrl = prefs.getString(_cacheKey) ?? '';
  }

  /// Simpan URL yang berhasil digunakan
  static Future<void> cacheUrl(String url) async {
    final normalized = url.replaceAll(RegExp(r'/$'), '');

    if (_cachedUrl == normalized) return;

    _cachedUrl = normalized;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, normalized);
  }

  /// Hapus cache URL (opsional, untuk debugging)
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    _cachedUrl = '';
  }
}