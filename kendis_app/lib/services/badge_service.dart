import '../core/api_client.dart'; 

class BadgeCounts {
  final int tugasBelumDijalankan;
  final int kegiatanBelumDipilih;
  final int laporanBelumDiisi;

  const BadgeCounts({
    this.tugasBelumDijalankan = 0,
    this.kegiatanBelumDipilih = 0,
    this.laporanBelumDiisi = 0,
  });

  factory BadgeCounts.fromJson(Map<String, dynamic> json) {
    return BadgeCounts(
      tugasBelumDijalankan: (json['tugas_belum_dijalankan'] ?? 0) as int,
      kegiatanBelumDipilih: (json['kegiatan_belum_dipilih'] ?? 0) as int,
      laporanBelumDiisi: (json['laporan_belum_diisi'] ?? 0) as int,
    );
  }
}

class BadgeService {
  /// Panggil GET /notifikasi/badge_count.php
  static Future<BadgeCounts> fetchBadgeCounts() async {
    final res = await ApiClient.get('/notifikasi/badge_count.php');
    final data = res['data'] as Map<String, dynamic>;
    return BadgeCounts.fromJson(data);
  }
}