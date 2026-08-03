import '../core/api_client.dart';

class PengaturanNotifikasiModel {
  final bool notifikasiPenugasan;
  final bool perubahanStatus;
  final bool informasiPengumuman;
  final bool suaraNotifikasi;

  const PengaturanNotifikasiModel({
    required this.notifikasiPenugasan,
    required this.perubahanStatus,
    required this.informasiPengumuman,
    required this.suaraNotifikasi,
  });

  factory PengaturanNotifikasiModel.fromJson(Map<String, dynamic> json) {
    return PengaturanNotifikasiModel(
      notifikasiPenugasan: json['notifikasi_penugasan'] == true,
      perubahanStatus: json['perubahan_status'] == true,
      informasiPengumuman: json['informasi_pengumuman'] == true,
      suaraNotifikasi: json['suara_notifikasi'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifikasi_penugasan': notifikasiPenugasan,
      'perubahan_status': perubahanStatus,
      'informasi_pengumuman': informasiPengumuman,
      'suara_notifikasi': suaraNotifikasi,
    };
  }

  PengaturanNotifikasiModel copyWith({
    bool? notifikasiPenugasan,
    bool? perubahanStatus,
    bool? informasiPengumuman,
    bool? suaraNotifikasi,
  }) {
    return PengaturanNotifikasiModel(
      notifikasiPenugasan: notifikasiPenugasan ?? this.notifikasiPenugasan,
      perubahanStatus: perubahanStatus ?? this.perubahanStatus,
      informasiPengumuman: informasiPengumuman ?? this.informasiPengumuman,
      suaraNotifikasi: suaraNotifikasi ?? this.suaraNotifikasi,
    );
  }
}

class PengaturanNotifikasiService {
  // ============================================================
  // GET PENGATURAN NOTIFIKASI
  // ============================================================

  static Future<PengaturanNotifikasiModel> getPengaturan() async {
    final res = await ApiClient.get('/profil/pengaturan_notifikasi.php');

    return PengaturanNotifikasiModel.fromJson(
      res['data'] as Map<String, dynamic>,
    );
  }

  // ============================================================
  // SIMPAN PENGATURAN NOTIFIKASI
  // ============================================================

  static Future<void> simpanPengaturan(PengaturanNotifikasiModel pengaturan) async {
    await ApiClient.post(
      '/profil/pengaturan_notifikasi.php',
      pengaturan.toJson(),
    );
  }
}