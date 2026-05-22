import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class WeeklyActivityCard extends StatelessWidget {
  final List<String> days = const ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];
  final List<int> barHeights = const [0, 0, 0, 0, 0, 0, 0];

  const WeeklyActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    const double minH = 8.0;
    const double maxH = 80.0;
    final int peak = barHeights.reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TempusColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TempusColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TempusColors.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: TempusColors.accentBlue.withOpacity(0.2),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.bar_chart_rounded,
                    color: TempusColors.accentBlue,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Atividade — 7 Dias',
                style: TextStyle(
                  color: TempusColors.textSub,
                  fontSize: 13,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: days.asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;
              final value = barHeights[index];
              final barH = (peak > 0 ? (value / peak) * maxH : minH).clamp(minH, maxH);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        height: barH,
                        decoration: BoxDecoration(
                          gradient: value > 0
                              ? TempusColors.gradient
                              : const LinearGradient(
                                  colors: [TempusColors.border, TempusColors.border],
                                ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: TempusColors.textSub,
                          fontSize: 9,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
