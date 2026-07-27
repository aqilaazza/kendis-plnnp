class LaporanDetailModel {
  final int idPenugasan;
  final int odoStart;
  final int odoStop;
  final double literBbm;
  final double rupiahBbm;
  final double rupiahTol;
  final double rupiahParkir;
  final String? tanggalLapor;
  final String? fotoBbmUrl;
  final String? fotoTolUrl;
  final String? fotoParkirUrl;
  final String? fotoOdoStartUrl;
  final String? fotoOdoStopUrl;

  LaporanDetailModel({
    required this.idPenugasan,
    required this.odoStart,
    required this.odoStop,
    required this.literBbm,
    required this.rupiahBbm,
    required this.rupiahTol,
    required this.rupiahParkir,
    this.tanggalLapor,
    this.fotoBbmUrl,
    this.fotoTolUrl,
    this.fotoParkirUrl,
    this.fotoOdoStartUrl,
    this.fotoOdoStopUrl,
  });

  factory LaporanDetailModel.fromJson(Map<String, dynamic> json) {
    return LaporanDetailModel(
      idPenugasan: int.parse(json['id_penugasan'].toString()),
      odoStart: int.tryParse(json['odo_start']?.toString() ?? '0') ?? 0,
      odoStop: int.tryParse(json['odo_stop']?.toString() ?? '0') ?? 0,
      literBbm: double.tryParse(json['liter_bbm']?.toString() ?? '0') ?? 0,
      rupiahBbm: double.tryParse(json['rupiah_bbm']?.toString() ?? '0') ?? 0,
      rupiahTol: double.tryParse(json['rupiah_tol']?.toString() ?? '0') ?? 0,
      rupiahParkir: double.tryParse(json['rupiah_parkir']?.toString() ?? '0') ?? 0,
      tanggalLapor: json['tanggal_lapor'],
      fotoBbmUrl: json['foto_bbm'],
      fotoTolUrl: json['foto_tol'],
      fotoParkirUrl: json['foto_parkir'],
      fotoOdoStartUrl: json['foto_odo_start'],
      fotoOdoStopUrl: json['foto_odo_stop'],
    );
  }

  int get jarakKm => odoStop >= odoStart ? odoStop - odoStart : 0;

  /// Backend cuma nyimpen total rupiah_bbm (bukan harga/liter terpisah),
  /// jadi harga per liter dihitung balik di sini.
  double get hargaPerLiter => literBbm > 0 ? rupiahBbm / literBbm : 0;

  double get totalBiaya => rupiahBbm + rupiahTol + rupiahParkir;
}