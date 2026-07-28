class KegiatanModel {
  final int id;
  final String namaKegiatan;
  final String tujuan;
  final String tanggal;
  final String jam;

  // ID driver yang mengambil kegiatan
  final int? idDriver;

  // Nama driver yang mengambil kegiatan
  final String? namaDriver;

  // NID driver yang mengambil kegiatan
  final String? nidDriver;

  KegiatanModel({
    required this.id,
    required this.namaKegiatan,
    required this.tujuan,
    required this.tanggal,
    required this.jam,
    this.idDriver,
    this.namaDriver,
    this.nidDriver,
  });

  // ============================================================
  // CEK APAKAH SUDAH DIAMBIL DRIVER
  // ============================================================

  bool get sudahDiambil {
    return idDriver != null;
  }

  factory KegiatanModel.fromJson(
    Map<String, dynamic> json,
  ) {
    int? parsedIdDriver;

    final rawIdDriver = json['id_driver'];

    if (rawIdDriver != null &&
        rawIdDriver.toString().isNotEmpty &&
        rawIdDriver.toString() != '0') {
      parsedIdDriver = int.tryParse(
        rawIdDriver.toString(),
      );
    }

    return KegiatanModel(
      id: int.tryParse(
            json['id'].toString(),
          ) ??
          0,

      namaKegiatan:
          json['nama_kegiatan']?.toString() ?? '',

      tujuan:
          json['tujuan']?.toString() ?? '',

      tanggal:
          json['tanggal']?.toString() ?? '',

      jam:
          json['jam']?.toString() ?? '',

      idDriver:
          parsedIdDriver,

      namaDriver:
          json['nama_driver']?.toString(),

      nidDriver:
          json['nid_driver']?.toString(),
    );
  }
}


// ============================================================
// NOTIFIKASI MODEL
// ============================================================

class NotifikasiModel {
  final int id;
  final String judul;
  final String pesan;
  final bool isRead;
  final String createdAt;

  NotifikasiModel({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.isRead,
    required this.createdAt,
  });

  factory NotifikasiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return NotifikasiModel(
      id: int.tryParse(
            json['id'].toString(),
          ) ??
          0,

      judul:
          json['judul']?.toString() ?? '',

      pesan:
          json['pesan']?.toString() ?? '',

      isRead:
          json['is_read'].toString() == '1',

      createdAt:
          json['created_at']?.toString() ?? '',
    );
  }
}