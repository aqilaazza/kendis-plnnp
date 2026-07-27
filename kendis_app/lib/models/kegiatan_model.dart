class KegiatanModel {
  final int id;
  final String namaKegiatan;
  final String tujuan;
  final String tanggal;
  final String jam;
  final int? idDriver;

  KegiatanModel({
    required this.id,
    required this.namaKegiatan,
    required this.tujuan,
    required this.tanggal,
    required this.jam,
    required this.idDriver,
  });

  // ============================================================
  // CEK APAKAH KEGIATAN SUDAH DIAMBIL DRIVER
  // ============================================================

  bool get sudahDiambil => idDriver != null;

  factory KegiatanModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return KegiatanModel(
      id: int.parse(
        json['id'].toString(),
      ),

      namaKegiatan:
          json['nama_kegiatan']?.toString() ?? '',

      tujuan:
          json['tujuan']?.toString() ?? '',

      tanggal:
          json['tanggal']?.toString() ?? '',

      jam:
          json['jam']?.toString() ?? '',

      idDriver:
          json['id_driver'] == null ||
                  json['id_driver'].toString() == '0' ||
                  json['id_driver'].toString().isEmpty
              ? null
              : int.tryParse(
                  json['id_driver'].toString(),
                ),
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
      id: int.parse(
        json['id'].toString(),
      ),
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