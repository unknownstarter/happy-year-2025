import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:happy_year_2025/providers/fortune_provider.dart';
import 'package:happy_year_2025/widgets/chat_message.dart';
import 'package:happy_year_2025/widgets/chat_input.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      } catch (e) {
        debugPrint('Scroll error: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
      body: Column(
        children: [
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
                    _scrollToBottom();
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
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
    );
  }
}
