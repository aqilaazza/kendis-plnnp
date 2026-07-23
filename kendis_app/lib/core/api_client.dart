import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// PENTING: Ganti sesuai alamat backend PHP kamu di Laragon.
/// - Kalau test di Android Emulator: gunakan 10.0.2.2 (bukan localhost/127.0.0.1)
/// - Kalau test di HP fisik (satu WiFi dgn laptop): gunakan IP laptop, misal 192.168.1.5
/// - Nama folder default Laragon: taruh folder kendis_api di C:\laragon\www\kendis_api
class ApiConfig {
  static const String baseUrl = 'http://localhost/kendis-plnnp/kendis_api';
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

class ApiClient {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final token = await _getToken();
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    return _handleResponse(res);
  }

  /// Untuk submit laporan dengan foto (multipart/form-data)
  static Future<Map<String, dynamic>> postMultipart(
    String endpoint,
    Map<String, String> fields,
    Map<String, XFile?> files,
  ) async {
    final token = await _getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final request = http.MultipartRequest('POST', uri);
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);

    for (final entry in files.entries) {
      final file = entry.value;
      if (file == null) continue;

      // XFile.readAsBytes() jalan seragam di web MAUPUN Android/iOS/Desktop —
      // gak perlu percabangan kIsWeb lagi kayak sebelumnya dengan dart:io File
      // (yang bahkan .path / .readAsBytes()-nya sendiri gak bisa dipakai di web).
      final bytes = await file.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(entry.key, bytes, filename: file.name),
      );
    }

    final streamedRes = await request.send();
    final res = await http.Response.fromStream(streamedRes);
    return _handleResponse(res);
  }

  static Map<String, dynamic> _handleResponse(http.Response res) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Respons server tidak valid (${res.statusCode})', res.statusCode);
    }

    if (res.statusCode >= 200 && res.statusCode < 300 && body['success'] == true) {
      return body;
    }
    throw ApiException(body['message'] ?? 'Terjadi kesalahan', res.statusCode);
  }
}