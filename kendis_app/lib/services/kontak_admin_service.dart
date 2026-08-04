import '../core/api_client.dart';

class KontakAdminModel {
  final String nama;
  final String nomorWhatsapp;
  final String pesanDefault;

  const KontakAdminModel({
    required this.nama,
    required this.nomorWhatsapp,
    required this.pesanDefault,
  });

  factory KontakAdminModel.fromJson(Map<String, dynamic> json) {
    return KontakAdminModel(
      nama: json['nama'] ?? '-',
      nomorWhatsapp: json['nomor_whatsapp'] ?? '',
      pesanDefault: json['pesan_default'] ?? '',
    );
  }
}

class KontakAdminService {
  // ============================================================
  // GET KONTAK ADMIN
  // ============================================================

  static Future<KontakAdminModel> getKontakAdmin() async {
    final res = await ApiClient.get('/profil/kontak_admin.php');

    return KontakAdminModel.fromJson(res['data'] as Map<String, dynamic>);
  }
}