import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Kompres gambar bukti sebelum di-upload: di-resize supaya sisi terpanjang
/// maksimal [maxDimension] px (aspect ratio dijaga) lalu di-encode ulang ke
/// JPEG dengan [quality]. Hasilnya jauh lebih kecil dibanding file asli
/// kamera, jadi upload laporan lebih cepat dan hemat kuota.
const int _maxDimension = 1600;
const int _quality = 50;

/// Mengembalikan bytes JPEG hasil kompresi; kalau gagal (mis. format tidak
/// didukung), kembalikan [fallback] supaya upload tetap jalan.
Future<Uint8List> compressImageBytes(Uint8List bytes, {Uint8List? fallback}) async {
  try {
    final out = await FlutterImageCompress.compressWithList(
      bytes,
      format: CompressFormat.jpeg,
      quality: _quality,
      minWidth: _maxDimension,
      minHeight: _maxDimension,
    );
    if (out.isNotEmpty) return out;
  } catch (_) {
    // abai: pakai fallback
  }
  return fallback ?? bytes;
}

/// Ganti ekstensi nama file jadi .jpg karena hasil kompresi selalu JPEG.
String jpegFileName(String name) {
  final base = name.replaceAll(RegExp(r'\.[^.]+$'), '');
  return '$base.jpg';
}