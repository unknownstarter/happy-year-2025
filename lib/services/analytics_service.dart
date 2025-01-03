import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // 페이지뷰 이벤트
  static Future<void> logPageView(String screenName) async {
    await analytics.logEvent(
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
    await analytics.logEvent(
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
    await analytics.logEvent(
      name: 'fortune_response',
      parameters: {
        'success': isSuccess,
        'error_message': errorMessage ?? '',
      },
    );
  }
}
