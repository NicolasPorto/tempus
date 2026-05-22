import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class TimerHeader extends StatelessWidget {
  const TimerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Timer',
            style: TextStyle(
              color: TempusColors.text,
              fontSize: 30,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Organize seus estudos com o método Pomodoro',
            style: TextStyle(
              color: TempusColors.textSub,
              fontSize: 13,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
