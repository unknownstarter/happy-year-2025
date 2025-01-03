import 'package:flutter/foundation.dart';
import 'package:happy_year_2025/models/chat_message_model.dart';
import 'package:happy_year_2025/services/api_service.dart';

class FortuneProvider with ChangeNotifier {
  String? _name;
  String? _gender;
  DateTime? _birthDateTime;
  Map<String, String>? _fortuneResult;
  bool _isConfirming = false;
  String? _lastInput;

  String? get name => _name;
  String? get gender => _gender;
  DateTime? get birthDateTime => _birthDateTime;
  Map<String, String>? get fortuneResult => _fortuneResult;
  bool get isConfirming => _isConfirming;
  String? get lastInput => _lastInput;

  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  void setGender(String gender) {
    _gender = gender;
    notifyListeners();
  }

  void setBirthDateTime(DateTime dateTime) {
    _birthDateTime = dateTime;
    notifyListeners();
  }

  void setFortuneResult(Map<String, String> result) {
    _fortuneResult = result;
    notifyListeners();
  }

  void reset() {
    _name = null;
    _gender = null;
    _birthDateTime = null;
    _fortuneResult = null;
    notifyListeners();
  }

  final List<ChatMessageModel> _messages = [];
  List<ChatMessageModel> get messages => List.unmodifiable(_messages);

  void addMessage(String message, bool isUser) {
    _messages.add(ChatMessageModel(message: message, isUser: isUser));
    notifyListeners();
  }

  void setLastInput(String input) {
    _lastInput = input;
    _isConfirming = true;
    notifyListeners();
  }

  void confirmInput(bool isConfirmed) {
    _isConfirming = false;
    if (!isConfirmed) {
      if (_name == null) {
        addMessage('이름을 다시 입력해주세요!', false);
      } else if (_gender == null) {
        addMessage('성별을 다시 입력해주세요.', false);
        addMessage('(예시: 남성 또는 여성)', false);
      } else if (_birthDateTime == null) {
        addMessage('생년월일과 시간을 다시 입력해주세요.', false);
        addMessage('(예시: 1998년 12월 1일, 19:00)', false);
      }
      _lastInput = null;
    }
    notifyListeners();
  }

  Future<void> analyzeFortune() async {
    if (_name == null || _gender == null || _birthDateTime == null) return;

    addMessage('2025년 운세를 분석하고 있습니다...', false);

    final fortune = await ApiService.getFortune(
      name: _name!,
      gender: _gender!,
      birthDateTime: _birthDateTime!,
    );

    setFortuneResult(fortune);

    // 운세 결과 메시지 추가
    fortune.forEach((key, value) {
      addMessage('$key\n$value', false);
    });
  }

  FortuneProvider() {
    addMessage(
      '안녕하세요! 2025년이 왔습니다 🥳 올해에는 어떤 것들이 기다리는지 운세를 봐드릴게요. 이름을 알려주세요!',
      false,
    );
  }
}
