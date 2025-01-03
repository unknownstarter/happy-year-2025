import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = const String.fromEnvironment('API_URL',
      defaultValue: 'http://localhost:8000' // 개발용 기본값
      );

  static Future<Map<String, String>> getFortune({
    required String name,
    required String gender,
    required DateTime birthDateTime,
  }) async {
    try {
      print('Request data:');
      print('Name: $name');
      print('Gender: $gender');
      print('Birth: $birthDateTime');

      final response = await http.post(
        Uri.parse('$baseUrl/api/fortune'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonEncode({
          'name': name,
          'gender': gender,
          'birthDateTime': birthDateTime.toIso8601String(),
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print('Response data: $data');
        return Map<String, String>.from(data['fortune']);
      } else if (response.statusCode == 429) {
        return {'오류': '일일 사용량을 초과했습니다. 내일 다시 시도해주세요.'};
      } else {
        print('Error response: ${utf8.decode(response.bodyBytes)}');
        return {'오류': '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'};
      }
    } catch (e) {
      print('Network error: $e');
      return {'오류': '네트워크 오류가 발생했습니다. 인터넷 연결을 확인해주세요.'};
    }
  }
}
