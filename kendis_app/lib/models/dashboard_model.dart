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
    // 1. Parsing statistik umum
    final stats = (json['statistik'] as Map<String, dynamic>?) ?? json;

    // 2. Handling fleksibel untuk list data dari JSON MySQL
    final list = (json['penugasan_aktif'] as List?) ?? (json['tasks'] as List?) ?? [];
    
    final costList = (json['cost_periode'] as List?) ?? 
                     (json['biaya_per_kategori'] as List?) ?? 
                     (json['cost_categories'] as List?) ?? [];
                     
    final cityList = (json['tujuan_terpopuler'] as List?) ?? 
                     (json['top_cities'] as List?) ?? 
                     (json['destinations'] as List?) ?? [];
                     
    final aktivitasList = (json['aktivitas_terakhir'] as List?) ?? 
                          (json['aktivitas_terbaru'] as List?) ?? 
                          (json['recent_activities'] as List?) ?? [];

    return DashboardModel(
      tugasAktif: int.tryParse('${stats['tugas_aktif'] ?? json['tugas_aktif']}') ?? 0,
      tugasSelesai: int.tryParse('${stats['tugas_selesai'] ?? json['tugas_selesai']}') ?? 0,
      rataRating: (stats['rata_rating'] as num?)?.toDouble(),
      
      penugasanAktif: list
          .map((e) => PenugasanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
          
      jumlahLaporanBulanIni: int.tryParse('${json['jumlah_laporan'] ?? json['jumlah_nota'] ?? json['total_nota']}'),
      totalKmBulanIni: (json['total_km'] as num?)?.toDouble(),
      totalRupiahBulanIni: (json['total_rupiah'] ?? json['total_biaya'] as num?)?.toDouble(),
      perluLaporan: int.tryParse('${json['perlu_laporan'] ?? json['tugas_perlu_laporan']}'),
      notifikasiUnread: int.tryParse('${json['notifikasi_belum_dibaca'] ?? json['unread_notifications']}'),
      
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
        label: json['label'] ?? json['bulan'] ?? json['month'] ?? '',
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
        kota: json['kota'] ?? json['city'] ?? json['city_name'] ?? '',
        jumlahTrip: int.tryParse('${json['jumlah_trip'] ?? json['total_trip'] ?? json['trip_count']}') ?? 0,
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
  final String kodeRequest;
  final int idPenugasan;

  const AktivitasItem({
    required this.jenis,
    required this.judul,
    required this.subjudul,
    required this.waktu,
    required this.nilai,
    required this.satuan,
    required this.status,
    this.kodeRequest = '',
    this.idPenugasan = 0,
  });

  factory AktivitasItem.fromJson(Map<String, dynamic> json) {
    final rawNilai = json['nilai'] ?? json['value'] ?? json['amount'];
    return AktivitasItem(
      jenis: json['jenis'] ?? json['category'] ?? json['type'] ?? 'perjalanan',
      judul: json['judul'] ?? json['title'] ?? '',
      subjudul: json['subjudul'] ?? json['subtitle'] ?? '',
      waktu: json['waktu'] ?? json['time'] ?? '',
      nilai: rawNilai is num ? rawNilai.toString() : (rawNilai?.toString() ?? '0'),
      satuan: json['satuan'] ?? json['unit'] ?? 'km',
      status: json['status'] ?? '',
      kodeRequest: json['kode_request'] ?? '',
      idPenugasan: int.tryParse('${json['id_penugasan'] ?? json['task_id']}') ?? 0,
    );
  }
}