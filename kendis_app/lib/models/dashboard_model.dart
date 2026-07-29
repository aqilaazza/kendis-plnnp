import 'penugasan_model.dart';

class DashboardModel {
  final int tugasAktif;
  final int tugasSelesai;
  final double? rataRating;
  final List<PenugasanModel> penugasanAktif;
  final int? jumlahLaporanBulanIni;
  final double? totalKmBulanIni;
  final double? totalRupiahBulanIni;

  final int? perluLaporan;
  final List<CostByCategory>? biayaPerKategori;
  final List<TopCity>? topCities;
  final int? notifikasiUnread;
  final List<AktivitasItem>? aktivitasTerbaru;

  DashboardModel({
    required this.tugasAktif,
    required this.tugasSelesai,
    this.rataRating,
    this.penugasanAktif = const [],
    this.jumlahLaporanBulanIni,
    this.totalKmBulanIni,
    this.totalRupiahBulanIni,
    this.perluLaporan,
    this.biayaPerKategori,
    this.topCities,
    this.notifikasiUnread,
    this.aktivitasTerbaru,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final stats = (json['statistik'] as Map<String, dynamic>?) ?? {};
    final list = (json['penugasan_aktif'] as List?) ?? [];
    final costList = (json['cost_periode'] as List?) ?? [];
    final cityList = (json['tujuan_terpopuler'] as List?) ?? [];
    final aktivitasList = (json['aktivitas_terakhir'] as List?) ?? [];
    return DashboardModel(
      tugasAktif: int.tryParse('${stats['tugas_aktif']}') ?? 0,
      tugasSelesai: int.tryParse('${stats['tugas_selesai']}') ?? 0,
      rataRating: (stats['rata_rating'] as num?)?.toDouble(),
      penugasanAktif: list
          .map((e) => PenugasanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      jumlahLaporanBulanIni: int.tryParse('${json['jumlah_laporan']}'),
      totalKmBulanIni: (json['total_km'] as num?)?.toDouble(),
      totalRupiahBulanIni: (json['total_rupiah'] as num?)?.toDouble(),
      perluLaporan: int.tryParse('${json['perlu_laporan']}'),
      notifikasiUnread: int.tryParse('${json['notifikasi_belum_dibaca']}'),
      biayaPerKategori: costList
          .map((e) => CostByCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      topCities: cityList
          .map((e) => TopCity.fromJson(e as Map<String, dynamic>))
          .toList(),
      aktivitasTerbaru: aktivitasList
          .map((e) => AktivitasItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CostByCategory {
  final String label;
  final double bbm;
  final double parkir;
  final double tol;

  const CostByCategory({
    required this.label,
    required this.bbm,
    required this.parkir,
    required this.tol,
  });

  factory CostByCategory.fromJson(Map<String, dynamic> json) => CostByCategory(
        label: json['label'] ?? '',
        bbm: (json['bbm'] as num?)?.toDouble() ?? 0,
        parkir: (json['parkir'] as num?)?.toDouble() ?? 0,
        tol: (json['tol'] as num?)?.toDouble() ?? 0,
      );
}

class TopCity {
  final String kota;
  final int jumlahTrip;

  const TopCity({required this.kota, required this.jumlahTrip});

  factory TopCity.fromJson(Map<String, dynamic> json) => TopCity(
        kota: json['kota'] ?? '',
        jumlahTrip: int.tryParse('${json['jumlah_trip']}') ?? 0,
      );
}

class AktivitasItem {
  final String jenis;
  final String judul;
  final String subjudul;
  final String waktu;
  final String nilai;
  final String satuan;
  final String status;

  const AktivitasItem({
    required this.jenis,
    required this.judul,
    required this.subjudul,
    required this.waktu,
    required this.nilai,
    required this.satuan,
    required this.status,
  });

  factory AktivitasItem.fromJson(Map<String, dynamic> json) => AktivitasItem(
        jenis: json['jenis'] ?? 'perjalanan',
        judul: json['judul'] ?? '',
        subjudul: json['subjudul'] ?? '',
        waktu: json['waktu'] ?? '',
        nilai: json['nilai'] ?? '0',
        satuan: json['satuan'] ?? 'km',
        status: json['status'] ?? '',
      );
}