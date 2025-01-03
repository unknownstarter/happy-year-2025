import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      print('Analytics error: $e');
      // 에러가 발생해도 앱 실행에 영향을 주지 않도록 함
    }
  }

  // 페이지뷰 이벤트
  static Future<void> logPageView(String screenName) async {
    await logEvent(
      name: 'screen_view',
      parameters: {
        'screen_name': screenName,
      },
    );
  }

  // 운세 요청 이벤트
  static Future<void> logFortuneRequest({
    required String name,
    required String gender,
    required DateTime birthDateTime,
  }) async {
    await logEvent(
      name: 'fortune_request',
      parameters: {
        'user_gender': gender,
        'birth_year': birthDateTime.year.toString(),
      },
    );
  }

  // 운세 결과 수신 이벤트
  static Future<void> logFortuneResponse({
    required bool isSuccess,
    String? errorMessage,
  }) async {
    await logEvent(
      name: 'fortune_response',
      parameters: {
        'success': isSuccess,
        'error_message': errorMessage ?? '',
      },
    );
  }
}
