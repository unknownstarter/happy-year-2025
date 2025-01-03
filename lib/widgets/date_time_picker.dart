import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:happy_year_2025/providers/fortune_provider.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';

class DateTimePicker extends StatelessWidget {
  const DateTimePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () => _selectDateTime(context),
          child: const Text(
            '날짜와 시간 선택하기',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _selectDateTime(BuildContext context) {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(1900, 1, 1),
      maxTime: DateTime.now(),
      onConfirm: (dateTime) async {
        final provider = Provider.of<FortuneProvider>(context, listen: false);
        final formatter = DateFormat('yyyy년 MM월 dd일, HH:mm');
        final formattedDateTime = formatter.format(dateTime);

        provider.addMessage(formattedDateTime, true);
        provider.setBirthDateTime(dateTime);
        await provider.analyzeFortune();
      },
      currentTime: DateTime(1990),
      locale: LocaleType.ko,
    );
  }
}
