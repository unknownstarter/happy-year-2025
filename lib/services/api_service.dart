import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = String.fromEnvironment('API_URL',
      defaultValue: 'https://happy-year-2025-production.up.railway.app');

  static Future<Map<String, String>> getFortune({
    required String name,
    required String gender,
    required DateTime birthDateTime,
  }) async {
    try {
      final apiUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
      print('API URL: $apiUrl');
      print('Sending request to: ${apiUrl}api/fortune');
      print('Request body: ${jsonEncode({
            'name': name,
            'gender': gender,
            'birthDateTime': birthDateTime.toIso8601String(),
          })}');

      final response = await http.post(
        Uri.parse('${apiUrl}api/fortune'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Origin':
              'https://happy-year-2025-9mq5-2ku69kyls-noahs-projects-9b976b5c.vercel.app'
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
        print('Parsed response data: $data');
        return Map<String, String>.from(data['fortune']);
      } else {
        print('Error status code: ${response.statusCode}');
        print('Error response body: ${utf8.decode(response.bodyBytes)}');
        if (response.statusCode == 429) {
          return {'오류': '일일 사용량을 초과했습니다. 내일 다시 시도해주세요.'};
        }
        return {
          '오류': '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요. (${response.statusCode})'
        };
      }
    } catch (e, stackTrace) {
      print('Network error: $e');
      print('Stack trace: $stackTrace');
      return {'오류': '네트워크 오류가 발생했습니다. 인터넷 연결을 확인해주세요. ($e)'};
    }
  }
}
