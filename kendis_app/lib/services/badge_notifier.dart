import 'dart:async';
import 'package:flutter/foundation.dart';
import 'badge_service.dart';

class BadgeNotifier extends ChangeNotifier {
  BadgeNotifier._internal() {
    refresh();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => refresh());
  }
  static final BadgeNotifier instance = BadgeNotifier._internal();

  BadgeCounts counts = const BadgeCounts();
  bool _isRefreshing = false;
  Timer? _timer;

  Future<void> refresh() async {
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}