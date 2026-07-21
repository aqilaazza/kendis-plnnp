class PenugasanModel {
  final int id;
  final int idRequest;
  final String kodeRequest;
  final String tempatTujuan;
  final String? lokasiTujuan;
  final String tanggalBerangkat;
  final String jamBerangkat;
  final String? tanggalKembali;
  final String? jamKembali;
  final String kegiatan;
  final int jumlahPenumpang;
  final String statusValidasiPool;
  final bool isBerangkat;
  final String statusRequest;
  final String? nopol;
  final String? merkKendaraan;
  final String? warnaKendaraan;
  final String? namaPemohon;
  final String? hpPemohon;
  final String? namaAtasan;
  final double? totalPelaporan;
  final int? odoStart;
  final int? odoStop;

  PenugasanModel({
    required this.id,
    required this.idRequest,
    required this.kodeRequest,
    required this.tempatTujuan,
    this.lokasiTujuan,
    required this.tanggalBerangkat,
    required this.jamBerangkat,
    this.tanggalKembali,
    this.jamKembali,
    required this.kegiatan,
    required this.jumlahPenumpang,
    required this.statusValidasiPool,
    required this.isBerangkat,
    required this.statusRequest,
    this.nopol,
    this.merkKendaraan,
    this.warnaKendaraan,
    this.namaPemohon,
    this.hpPemohon,
    this.namaAtasan,
    this.totalPelaporan,
    this.odoStart,
    this.odoStop,
  });

  factory PenugasanModel.fromJson(Map<String, dynamic> json) {
    return PenugasanModel(
      id: int.parse(json['id'].toString()),
      idRequest: int.parse(json['id_request'].toString()),
      kodeRequest: json['kode_request'] ?? '',
      tempatTujuan: json['tempat_tujuan'] ?? '',
      lokasiTujuan: json['lokasi_tujuan'],
      tanggalBerangkat: json['req_tgl_berangkat'] ?? json['tanggal_berangkat'] ?? '',
      jamBerangkat: json['jam_berangkat'] ?? '',
      tanggalKembali: json['req_tgl_kembali'] ?? json['tanggal_kembali'],
      jamKembali: json['jam_kembali'],
      kegiatan: json['kegiatan'] ?? '',
      jumlahPenumpang: int.tryParse(json['jumlah_penumpang']?.toString() ?? '1') ?? 1,
      statusValidasiPool: json['status_validasi_atasan_pool'] ?? 'pending',
      isBerangkat: json['is_berangkat'].toString() == '1',
      statusRequest: json['status_request'] ?? '',
      nopol: json['nopol'],
      merkKendaraan: json['merk'],
      warnaKendaraan: json['warna'],
      namaPemohon: json['nama_pemohon'],
      hpPemohon: json['hp_pemohon'],
      namaAtasan: json['nama_atasan'],
      totalPelaporan: json['total_pelaporan'] != null ? double.tryParse(json['total_pelaporan'].toString()) : null,
      odoStart: json['odo_start'] != null ? int.tryParse(json['odo_start'].toString()) : null,
      odoStop: json['odo_stop'] != null ? int.tryParse(json['odo_stop'].toString()) : null,
    );
  }

  /// Jarak tempuh (km), null jika laporan belum diisi
  int? get jarakKm => (odoStart != null && odoStop != null && odoStop! >= odoStart!) ? odoStop! - odoStart! : null;

  /// true jika laporan driver untuk penugasan ini sudah pernah dikirim
  bool get sudahLapor => totalPelaporan != null;

  /// Label status yang ramah untuk ditampilkan ke driver
  String get statusLabel {
    switch (statusRequest) {
      case 'driver_assigned':
        return 'Menunggu Validasi';
      case 'approved_pool':
        return 'Siap Berangkat';
      case 'on_trip':
        return 'Dalam Perjalanan';
      case 'completed':
        return 'Selesai';
      case 'rated':
        return 'Selesai (Dinilai)';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return statusRequest;
    }
  }
}
