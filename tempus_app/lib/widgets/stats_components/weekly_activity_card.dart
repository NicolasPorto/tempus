import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class WeeklyActivityCard extends StatelessWidget {
  final List<String> days = const [
    'SEG',
    'TER',
    'QUA',
    'QUI',
    'SEX',
    'SÁB',
    'DOM',
  ];
  final List<int> barHeights = const [0, 0, 0, 0, 0, 0, 0];

  const WeeklyActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    const double MIN_BAR_HEIGHT = 10.0;
    const double MAX_BAR_HEIGHT = 100.0;
    final int maxTime = barHeights.reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.00, 0.00),
          end: Alignment(1.00, 1.00),
          colors: [Color(0xCC171717), Color(0xCC0A0A0A)],
        ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x19FFFEFE)),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 50,
            offset: Offset(0, 25),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(8),
                decoration: ShapeDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(0.00, 0.00),
                    end: Alignment(1.00, 1.00),
                    colors: [Color(0x19AC46FF), Color(0x192B7FFF)],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.bar_chart,
                    color: Colors.blueAccent.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: AutoSizeText(
                  'Atividade dos Últimos 7 Dias',
                  maxLines: 1,
                  minFontSize: 12,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFFF4F4F4),
                    fontSize: 16,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: days.asMap().entries.map((entry) {
              int index = entry.key;
              String day = entry.value;
              int value = barHeights[index];

              final double currentHeight = maxTime > 0
                  ? (value / maxTime) * MAX_BAR_HEIGHT
                  : MIN_BAR_HEIGHT;
              final double barHeight = currentHeight.clamp(
                MIN_BAR_HEIGHT,
                MAX_BAR_HEIGHT,
              );

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: barHeight,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFAC46FF), Color(0xFF2B7FFF)],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(14),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 28,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: ShapeDecoration(
                          color: const Color(0x7F262626),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Center(
                          child: AutoSizeText(
                            value.toString(),
                            maxLines: 1,
                            minFontSize: 8,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: value > 0
                                  ? const Color(0xFFF4F4F4)
                                  : const Color(0xFF525252),
                              fontSize: 16,
                              fontFamily: 'Arimo',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      AutoSizeText(
                        day,
                        maxLines: 1,
                        minFontSize: 10,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF737373),
                          fontSize: 16,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
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
