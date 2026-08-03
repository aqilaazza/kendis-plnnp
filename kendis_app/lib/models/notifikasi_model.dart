class NotifikasiModel {
  final int id;
  final int? idRequest;

  final String? kategori;

  final String? tipe;

  final String judul;
  final String pesan;
  final bool isRead;

  final DateTime createdAt;

  const NotifikasiModel({
    required this.id,
    required this.idRequest,
    required this.kategori,
    required this.tipe,
    required this.judul,
    required this.pesan,
    required this.isRead,
    required this.createdAt,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      idRequest: json['id_request'] == null
          ? null
          : int.tryParse(json['id_request'].toString()),
      kategori: json['kategori'] as String?,
      tipe: json['tipe'] as String?,
      judul: json['judul']?.toString() ?? '',
      pesan: json['pesan']?.toString() ?? '',
      isRead: json['is_read'].toString() == '1',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}