import '../core/api_client.dart';

class FaqModel {
  final int id;
  final String pertanyaan;
  final String jawaban;

  const FaqModel({
    required this.id,
    required this.pertanyaan,
    required this.jawaban,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      pertanyaan: json['pertanyaan'] ?? '',
      jawaban: json['jawaban'] ?? '',
    );
  }
}

class FaqService {
  // ============================================================
  // GET LIST FAQ
  // ============================================================

  static Future<List<FaqModel>> getList() async {
    final res = await ApiClient.get('/faq/list.php');

    final list = res['data'] as List;

    return list.map((e) => FaqModel.fromJson(e)).toList();
  }
}