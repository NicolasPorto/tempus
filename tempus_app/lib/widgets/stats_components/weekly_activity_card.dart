import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class WeeklyActivityCard extends StatefulWidget {
  final List<String> days;
  final List<int> barHeights;

  const WeeklyActivityCard({
    super.key,
    this.days = const ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'],
    this.barHeights = const [0, 0, 0, 0, 0, 0, 0],
  });

  @override
  State<WeeklyActivityCard> createState() => _WeeklyActivityCardState();
}

class _WeeklyActivityCardState extends State<WeeklyActivityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<CurvedAnimation> _barAnims;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _barAnims = _buildBarAnims();
    Future.microtask(() => _controller.forward());
  }

  List<CurvedAnimation> _buildBarAnims() {
    final n = widget.days.length;
    return List.generate(n, (i) {
      final delay = i / n;
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(
          (delay * 0.5).clamp(0.0, 1.0),
          (delay * 0.5 + 0.6).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      );
    });
  }

  @override
  void dispose() {
    for (final a in _barAnims) {
      a.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double minH = 8.0;
    const double maxH = 80.0;
    final int peak = widget.barHeights.reduce((a, b) => a > b ? a : b);
    final today = DateTime.now().weekday; // 1=Mon, 7=Sun

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
                  color: TempusColors.accentBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: TempusColors.accentBlue.withValues(alpha: 0.2),
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
            children: widget.days.asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;
              final value = widget.barHeights[index];
              final targetH =
                  (peak > 0 ? (value / peak) * maxH : minH).clamp(minH, maxH);
              final isToday = (index + 1) == today;
              final anim = _barAnims[index]; // cached — not recreated

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: anim,
                        builder: (_, __) => Container(
                          height: minH + (targetH - minH) * anim.value,
                          decoration: BoxDecoration(
                            gradient: value > 0
                                ? TempusColors.gradient
                                : LinearGradient(colors: [
                                    isToday
                                        ? TempusColors.border
                                            .withValues(alpha: 2.0)
                                        : TempusColors.border,
                                    isToday
                                        ? TempusColors.border
                                            .withValues(alpha: 2.0)
                                        : TempusColors.border,
                                  ]),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                            border: isToday && value == 0
                                ? Border.all(
                                    color: TempusColors.accent
                                        .withValues(alpha: 0.4),
                                    width: 1,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isToday
                              ? TempusColors.accent
                              : TempusColors.textSub,
                          fontSize: 9,
                          fontFamily: 'Arimo',
                          fontWeight: isToday
                              ? FontWeight.w700
                              : FontWeight.w500,
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
