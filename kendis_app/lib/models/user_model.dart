class UserModel {
  final int id;
  final String nid;
  final String nama;
  final String role;
  final String? jabatan;
  final String? divisi;
  final String? noHp;
  final String? noSim;
  final String? jenisSim;

  UserModel({
    required this.id,
    required this.nid,
    required this.nama,
    required this.role,
    this.jabatan,
    this.divisi,
    this.noHp,
    this.noSim,
    this.jenisSim,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.parse(json['id'].toString()),
      nid: json['nid'] ?? '',
      nama: json['nama'] ?? '',
      role: json['role'] ?? '',
      jabatan: json['jabatan'],
      divisi: json['divisi'],
      noHp: json['no_hp'],
      noSim: json['no_sim'],
      jenisSim: json['jenis_sim'],
    );
  }
}
