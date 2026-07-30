import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../models/penugasan_menunggu_model.dart';
import '../services/penugasan_service.dart';

class PenugasanMenungguProvider extends ChangeNotifier {
  List<PenugasanMenungguModel> _list = [];
  bool _loading = false;
  String? _error;
  int? _driverId;

  /// Set id penugasan yang sudah pernah ditampilkan popup-nya pada sesi ini,
  /// agar tidak muncul berulang-ulang dalam sesi yang sama.
  final Set<int> _shownIds = {};

  /// Set id penugasan yang sudah dikonfirmasi driver (disimpan permanen
  /// di SharedPreferences). Solusi sementara sampai ada kolom konfirmasi
  /// driver di database.
  Set<int> _confirmedIds = {};

  List<PenugasanMenungguModel> get list => _list;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasData => _list.isNotEmpty;

  /// Penugasan paling prioritas: sudah diurut oleh API (urgent DESC,
  /// tanggal ASC, jam ASC). Null bila list kosong.
  PenugasanMenungguModel? get penugasanPrioritas =>
      _list.isNotEmpty ? _list.first : null;

  bool isConfirmed(int id) => _confirmedIds.contains(id);
  bool isEverShown(int id) => _shownIds.contains(id);

  void markShown(int id) => _shownIds.add(id);

  Future<void> load({required int driverId}) async {
    _driverId = driverId;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _loadConfirmedIds();
      final rawList = await PenugasanService.getMenungguKonfirmasi();
      _list = rawList
          .where((p) =>
              !_confirmedIds.contains(p.id) && !_shownIds.contains(p.id))
          .toList();
      _loading = false;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
    } catch (e) {
      _error = 'Gagal memuat penugasan baru';
      _loading = false;
    }
    notifyListeners();
  }

  Future<void> refresh({required int driverId}) async {
    await load(driverId: driverId);
  }

  Future<void> terimaTugas(int id) async {
    if (_driverId == null) throw Exception('Driver ID tidak diketahui');
    _confirmedIds.add(id);
    _list.removeWhere((p) => p.id == id);
    await _saveConfirmedIds();
    notifyListeners();
  }

  Future<void> _loadConfirmedIds() async {
    if (_driverId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final key = 'penugasan_dikonfirmasi_$_driverId';
    final ids = prefs.getStringList(key) ?? [];
    _confirmedIds =
        ids.map((s) => int.tryParse(s) ?? 0).where((i) => i > 0).toSet();
  }

  Future<void> _saveConfirmedIds() async {
    if (_driverId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final key = 'penugasan_dikonfirmasi_$_driverId';
    await prefs.setStringList(
        key, _confirmedIds.map((i) => i.toString()).toList());
  }
}
