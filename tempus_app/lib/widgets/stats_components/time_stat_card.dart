import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class TimeStatCard extends StatelessWidget {
  final String realTime;
  final String plannedTime;
  final String avgTime;
  final List<Color> iconColors;
  final List<Color> barColors;
  final IconData icon;

  const TimeStatCard({
    super.key,
    required this.realTime,
    required this.plannedTime,
    required this.avgTime,
    required this.iconColors,
    required this.barColors,
    this.icon = Icons.access_time,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = barColors.first;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: TempusColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TempusColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: barColors),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: iconColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Center(
                          child: Icon(icon, color: accentColor, size: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Visão Geral de Tempo',
                        style: TextStyle(
                          color: TempusColors.textSub,
                          fontSize: 13,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _StatCol(label: 'Tempo Real', value: realTime),
                      _Divider(),
                      _StatCol(label: 'Planejado', value: plannedTime),
                      _Divider(),
                      _StatCol(label: 'Média/Sessão', value: avgTime),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: TempusColors.border,
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String label;
  final String value;

  const _StatCol({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: TempusColors.textSub,
              fontSize: 11,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            ),
            child: Text(
              key: ValueKey(value),
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: value == '...' ? TempusColors.textSub : TempusColors.text,
                fontSize: 20,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
