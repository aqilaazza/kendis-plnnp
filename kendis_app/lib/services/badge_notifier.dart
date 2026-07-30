import 'package:flutter/foundation.dart';
import 'badge_service.dart';

class BadgeNotifier extends ChangeNotifier {
  BadgeNotifier._internal();
  static final BadgeNotifier instance = BadgeNotifier._internal();

  BadgeCounts counts = const BadgeCounts();
  bool _isRefreshing = false;

  Future<void> refresh() async {
    // Cegah refresh dobel kalau ke-trigger beruntun (mis. timer + aksi user barengan)
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      counts = await BadgeService.fetchBadgeCounts();
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal memuat badge count: $e');
    } finally {
      _isRefreshing = false;
    }
  }
}