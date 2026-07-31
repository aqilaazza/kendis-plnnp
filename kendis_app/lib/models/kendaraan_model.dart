class KendaraanModel {
  final int id;
  final String nopol;
  final String? merk;
  final String? warna;
  final String? foto;
  final String? status;

  KendaraanModel({
    required this.id,
    required this.nopol,
    this.merk,
    this.warna,
    this.foto,
    this.status,
  });

  factory KendaraanModel.fromJson(Map<String, dynamic> json) {
    return KendaraanModel(
      id: int.parse(json['id'].toString()),
      nopol: json['nopol'] ?? '',
      merk: json['merk'],
      warna: json['warna'],
      foto: json['foto'],
      status: json['status'],
    );
  }
}