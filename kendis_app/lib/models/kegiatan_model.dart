class KegiatanModel {
  final int id;
  final String namaKegiatan;
  final String tujuan;
  final String tanggal;
  final String jam;

  KegiatanModel({
    required this.id,
    required this.namaKegiatan,
    required this.tujuan,
    required this.tanggal,
    required this.jam,
  });

  factory KegiatanModel.fromJson(Map<String, dynamic> json) {
    return KegiatanModel(
      id: int.parse(json['id'].toString()),
      namaKegiatan: json['nama_kegiatan'] ?? '',
      tujuan: json['tujuan'] ?? '',
      tanggal: json['tanggal'] ?? '',
      jam: json['jam'] ?? '',
    );
  }
}

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

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      id: int.parse(json['id'].toString()),
      judul: json['judul'] ?? '',
      pesan: json['pesan'] ?? '',
      isRead: json['is_read'].toString() == '1',
      createdAt: json['created_at'] ?? '',
    );
  }
}
