import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:happy_year_2025/providers/fortune_provider.dart';

class GenderButtons extends StatelessWidget {
  const GenderButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(context, '남성'),
        const SizedBox(width: 16),
        _buildButton(context, '여성'),
      ],
    );
  }

  Widget _buildButton(BuildContext context, String gender) {
    return ElevatedButton(
      onPressed: () {
        final provider = Provider.of<FortuneProvider>(context, listen: false);
        provider.setGender(gender);
        provider.addMessage(gender, true);
        provider.addMessage(
          '생년월일과 시간을 입력해주세요! (예: 1998년 12월 1일, 19:00)',
          false,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: const Size(80, 32),
      ),
      child: Text(
        gender,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
