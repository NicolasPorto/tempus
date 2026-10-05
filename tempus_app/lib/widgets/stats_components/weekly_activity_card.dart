import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../common/ui.dart';

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

  String _short(int m) {
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    final r = m % 60;
    return r == 0 ? '${h}h' : '${h}h${r.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    const double minH = 6.0;
    const double maxH = 96.0;
    final int peak = widget.barHeights.reduce((a, b) => a > b ? a : b);
    final int total = widget.barHeights.fold(0, (a, b) => a + b);
    final activeDays = widget.barHeights.where((v) => v > 0).length;
    final today = DateTime.now().weekday; // 1=Mon, 7=Sun

    return TempusCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconTile(
                  icon: Icons.bar_chart_rounded, color: TempusColors.accentBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Esta semana',
                      style: TextStyle(
                        color: TempusColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '$activeDays de 7 dias com estudo',
                      style: const TextStyle(
                        color: TempusColors.textSub,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatMinutes(total),
                style: const TextStyle(
                  color: TempusColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: maxH + 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: widget.days.asMap().entries.map((entry) {
                final index = entry.key;
                final day = entry.value;
                final value = widget.barHeights[index];
                final targetH = (peak > 0 ? (value / peak) * maxH : minH)
                    .clamp(minH, maxH);
                final isToday = (index + 1) == today;
                final isFuture = (index + 1) > today;
                final anim = _barAnims[index]; // cached — not recreated

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (value > 0)
                          FadeTransition(
                            opacity: anim,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                _short(value),
                                maxLines: 1,
                                style: TextStyle(
                                  color: isToday
                                      ? TempusColors.text
                                      : TempusColors.textSub,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        AnimatedBuilder(
                          animation: anim,
                          builder: (_, __) => Container(
                            height: minH + (targetH - minH) * anim.value,
                            decoration: BoxDecoration(
                              gradient: value > 0
                                  ? LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: isToday
                                          ? const [
                                              Color(0xFFC084FC),
                                              TempusColors.accent,
                                            ]
                                          : [
                                              TempusColors.accent
                                                  .withValues(alpha: 0.55),
                                              TempusColors.accent
                                                  .withValues(alpha: 0.30),
                                            ],
                                    )
                                  : null,
                              color: value > 0
                                  ? null
                                  : isFuture
                                      ? TempusColors.surfaceHigh
                                      : TempusColors.surfaceHigher,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: isToday && value > 0
                                  ? [
                                      BoxShadow(
                                        color: TempusColors.accent
                                            .withValues(alpha: 0.35),
                                        blurRadius: 12,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          day,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isToday
                                ? TempusColors.accentSoft
                                : TempusColors.textMuted,
                            fontSize: 10,
                            fontWeight:
                                isToday ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
