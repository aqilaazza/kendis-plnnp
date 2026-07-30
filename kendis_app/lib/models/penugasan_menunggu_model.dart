import 'package:intl/intl.dart';

class PenugasanMenungguModel {
  final int id;
  final String kodeRequest;
  final bool isUrgent;
  final String lokasiTujuan;
  final String tempatTujuan;
  final String tanggalBerangkat;
  final String jamBerangkat;
  final String status;

  PenugasanMenungguModel({
    required this.id,
    required this.kodeRequest,
    required this.isUrgent,
    required this.lokasiTujuan,
    required this.tempatTujuan,
    required this.tanggalBerangkat,
    required this.jamBerangkat,
    required this.status,
  });

  factory PenugasanMenungguModel.fromJson(Map<String, dynamic> json) {
    bool urgent = false;
    final u = json['is_urgent'];
    if (u is bool) {
      urgent = u;
    } else if (u is int) {
      urgent = u == 1;
    } else if (u is String) {
      urgent = u == '1' || u.toLowerCase() == 'true';
    }

    return PenugasanMenungguModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      kodeRequest: json['kode_request']?.toString() ?? '',
      isUrgent: urgent,
      lokasiTujuan: json['lokasi_tujuan']?.toString() ?? '',
      tempatTujuan: json['tempat_tujuan']?.toString() ?? '',
      tanggalBerangkat: json['tanggal_berangkat']?.toString() ?? '',
      jamBerangkat: json['jam_berangkat']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  DateTime? get jadwal {
    if (tanggalBerangkat.isEmpty) return null;
    try {
      final tgl = tanggalBerangkat.length >= 10
          ? tanggalBerangkat.substring(0, 10)
          : tanggalBerangkat;
      final waktu = jamBerangkat.length >= 8
          ? jamBerangkat.substring(0, 8)
          : jamBerangkat;
      return DateFormat('yyyy-MM-dd HH:mm:ss').parse('$tgl $waktu');
    } catch (_) {
      try {
        return DateTime.tryParse(tanggalBerangkat);
      } catch (_) {
        return null;
      }
    }
  }

  String get jadwalFormatted {
    final dt = jadwal;
    if (dt == null) return '-';
    return DateFormat('d MMM, HH:mm', 'id_ID').format(dt);
  }
}
