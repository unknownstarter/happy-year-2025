import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:happy_year_2025/providers/fortune_provider.dart';
import 'package:happy_year_2025/widgets/chat_message.dart';
import 'package:happy_year_2025/widgets/chat_input.dart';
import 'package:happy_year_2025/services/analytics_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 키이지뷰 이벤트 로깅
    AnalyticsService.logPageView('chat_screen');
    // 키보드가 나타날 때 스크롤 조정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(() {
        if (_scrollController.position.pixels !=
            _scrollController.position.maxScrollExtent) {
          _scrollToBottom();
        }
      });
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        // SafeArea 추가
        child: Column(
          children: [
            AppBar(
              toolbarHeight: 44,
              title: const Text(
                '2025년 신년 운세',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
            ),
            Image.asset(
              'assets/images/fortune_header.png',
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1, // 10% 투명도로 변경
                      child: Image.asset(
                        'assets/images/chat_background.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Consumer<FortuneProvider>(
                    builder: (context, provider, child) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom(); // 메시지 업데이트마다 스크롤
                      });
                      return ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.only(
                          left: 8,
                          right: 8,
                          top: 4,
                          bottom: MediaQuery.of(context).viewInsets.bottom +
                              4, // 키보드 높이만큼 패딩 추가
                        ),
                        itemCount: provider.messages.length,
                        itemBuilder: (context, index) {
                          final message = provider.messages[index];
                          return ChatMessage(
                            message: message.message,
                            isUser: message.isUser,
                          );
                        },
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: false,
                      );
                    },
                  ),
                ],
              ),
            ),
            const ChatInput(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
