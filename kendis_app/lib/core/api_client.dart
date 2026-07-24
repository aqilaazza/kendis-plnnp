import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

class ApiClient {
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final token = await _getToken();
    return _request(
      (url) => http.get(
        Uri.parse('$url$endpoint'),
        headers: _headers(token),
      ),
    );
  }

  static Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> body) async {
    final token = await _getToken();
    return _request(
      (url) => http.post(
        Uri.parse('$url$endpoint'),
        headers: _headers(token),
        body: jsonEncode(body),
      ),
    );
  }

  static Future<Map<String, dynamic>> postMultipart(
    String endpoint,
    Map<String, String> fields,
    Map<String, XFile?> files,
  ) async {
    final token = await _getToken();
    final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
    final request = http.MultipartRequest('POST', uri);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    for (final entry in files.entries) {
      final file = entry.value;
      if (file == null) continue;
      final bytes = await file.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(entry.key, bytes, filename: file.name),
      );
    }

    try {
      final streamedRes = await request.send();
      final res = await http.Response.fromStream(streamedRes);
      return _handleResponse(res);
    } on http.ClientException catch (e) {
      throw ApiException('Gagal menghubungi server (${e.message})');
    }
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  /// Coba request ke URL default. Gagal koneksi → fallback ke kandidat lain.
  static Future<Map<String, dynamic>> _request(
    Future<http.Response> Function(String url) requestFn,
  ) async {
    List<String> errors = [];

    for (final url in AppConfig.candidateUrls) {
      try {
        final res = await requestFn(url);
        return _handleResponse(res);
      } on http.ClientException catch (e) {
        errors.add(e.message);
      } catch (e) {
        if (e is ApiException) rethrow;
        errors.add(e.toString());
      }
    }

    throw ApiException(errors.first);
  }

  static Map<String, dynamic> _handleResponse(http.Response res) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        'Respons server tidak valid (${res.statusCode}). Body: ${res.body.length > 200 ? '${res.body.substring(0, 200)}...' : res.body}',
        res.statusCode,
      );
    }

    if (res.statusCode >= 200 && res.statusCode < 300 && body['status'] == true) {
      return body;
    }
    throw ApiException(body['message'] ?? 'Terjadi kesalahan', res.statusCode);
  }
}
