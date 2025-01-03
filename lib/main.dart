import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:happy_year_2025/providers/fortune_provider.dart';
import 'package:happy_year_2025/screens/chat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FortuneProvider(),
      child: MaterialApp(
        title: '2025년 운세',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black,
            primary: Colors.black,
            secondary: const Color(0xFFF5F5F5),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const ChatScreen(),
      ),
    );
  }
}
