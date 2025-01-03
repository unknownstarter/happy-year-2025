import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:happy_year_2025/providers/fortune_provider.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({super.key});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FortuneProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _handleInput(context, provider);
                  _controller.clear();
                }
              },
              decoration: InputDecoration(
                hintText: _getHintText(provider),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                _handleInput(context, provider);
                _controller.clear();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text(
              '전송',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _getHintText(FortuneProvider provider) {
    if (provider.name == null) {
      return '이름을 입력하세요';
    } else if (provider.gender == null) {
      return '성별을 입력하세요 (예: 남성 또는 여성)';
    } else if (provider.birthDateTime == null) {
      return '생년월일시를 입력하세요 (예: 1998년 12월 1일, 19시)';
    }
    return '';
  }

  void _handleInput(BuildContext context, FortuneProvider provider) {
    final input = _controller.text.trim();

    if (provider.isConfirming) {
      if (input.toLowerCase() == '예' ||
          input.toLowerCase() == '네' ||
          input.toLowerCase() == 'yes') {
        provider.addMessage('예', true);
        provider.confirmInput(true);
        if (provider.lastInput != null) {
          if (provider.name == null) {
            provider.setName(provider.lastInput!);
            provider.addMessage('성별을 입력해주세요! (예: 남성 또는 여성)', false);
          } else if (provider.gender == null) {
            provider.setGender(provider.lastInput!);
            provider.addMessage('생년월일시를 입력해주세요! (예: 1998년 12월 1일 19시)', false);
          } else if (provider.birthDateTime == null) {
            try {
              final dateTime = _parseDateTimeString(provider.lastInput!);
              provider.setBirthDateTime(dateTime);
              provider.analyzeFortune();
            } catch (e) {
              provider.addMessage('날짜 형식이 잘못되었습니다. 다시 입력해주세요.', false);
            }
          }
        }
      } else if (input.toLowerCase() == '아니오' ||
          input.toLowerCase() == '아니요' ||
          input.toLowerCase() == 'no') {
        provider.addMessage('아니오', true);
        provider.confirmInput(false);
      } else {
        provider.addMessage('예 또는 아니오로 대답해주세요.', false);
      }
      return;
    }

    provider.addMessage(input, true);

    if (provider.name == null) {
      provider.setLastInput(input);
      provider.addMessage('입력하신 이름이 "$input" 맞나요? (예/아니오)', false);
    } else if (provider.gender == null) {
      if (input == '남성' || input == '여성') {
        provider.setLastInput(input);
        provider.addMessage('성별을 "$input"(으)로 입력하셨습니다. 맞나요? (예/아니오)', false);
      } else {
        provider.addMessage('성별은 남성 또는 여성으로 입력해주세요.', false);
      }
    } else if (provider.birthDateTime == null) {
      try {
        _parseDateTimeString(input);
        provider.setLastInput(input);
        provider.addMessage('입력하신 생년월일시가 "$input" 맞나요? (예/아니오)', false);
      } catch (e) {
        provider.addMessage('올바른 형식으로 입력해주세요. (예: 1998년 12월 1일, 19시)', false);
      }
    }
  }

  DateTime _parseDateTimeString(String input) {
    // 1998년 12월 1일, 19시 형식 파싱
    final regex = RegExp(r'(\d{4})년\s*(\d{1,2})월\s*(\d{1,2})일,?\s*(\d{1,2})시');
    final match = regex.firstMatch(input);

    if (match == null) {
      throw FormatException('Invalid date format');
    }

    return DateTime(
      int.parse(match.group(1)!), // 년
      int.parse(match.group(2)!), // 월
      int.parse(match.group(3)!), // 일
      int.parse(match.group(4)!), // 시
    );
  }
}
