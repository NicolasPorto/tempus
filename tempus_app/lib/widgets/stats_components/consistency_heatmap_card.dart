import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../common/ui.dart';

/// Mapa de calor de consistência: 12 semanas × 7 dias, colunas por semana
/// (segunda → domingo), intensidade pelo tempo estudado no dia.
class ConsistencyHeatmapCard extends StatefulWidget {
  final Map<DateTime, int> minutesByDay;
  final int weeks;

  const ConsistencyHeatmapCard({
    super.key,
    required this.minutesByDay,
    this.weeks = 12,
  });

  @override
  State<ConsistencyHeatmapCard> createState() => _ConsistencyHeatmapCardState();
}

class _ConsistencyHeatmapCardState extends State<ConsistencyHeatmapCard> {
  DateTime? _selected;

  static const _levels = [0, 1, 30, 60, 120]; // limites em minutos

  int _level(int minutes) {
    var l = 0;
    for (var i = 1; i < _levels.length; i++) {
      if (minutes >= _levels[i]) l = i;
    }
    return l;
  }

  Color _color(int level) {
    switch (level) {
      case 0:
        return TempusColors.surfaceHigher;
      case 1:
        return TempusColors.accent.withValues(alpha: 0.28);
      case 2:
        return TempusColors.accent.withValues(alpha: 0.52);
      case 3:
        return TempusColors.accent.withValues(alpha: 0.78);
      default:
        return const Color(0xFFC084FC);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisMonday = today.subtract(Duration(days: today.weekday - 1));
    final firstMonday =
        thisMonday.subtract(Duration(days: 7 * (widget.weeks - 1)));

    var activeDays = 0;
    var best = 0;
    widget.minutesByDay.forEach((day, m) {
      if (!day.isBefore(firstMonday) && m > 0) activeDays++;
      if (m > best) best = m;
    });

    final selected = _selected;
    final selectedMinutes =
        selected == null ? 0 : (widget.minutesByDay[selected] ?? 0);

    return TempusCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconTile(
                  icon: Icons.grid_view_rounded, color: TempusColors.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Consistência',
                      style: TextStyle(
                        color: TempusColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '$activeDays dias ativos nas últimas ${widget.weeks} semanas',
                      style: const TextStyle(
                        color: TempusColors.textSub,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(builder: (context, constraints) {
            const labelW = 18.0;
            const gap = 4.0;
            final cell = ((constraints.maxWidth - labelW - gap * widget.weeks) /
                    widget.weeks)
                .clamp(8.0, 22.0);
            const dayLabels = ['S', '', 'Q', '', 'S', '', 'D'];

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: labelW,
                  child: Column(
                    children: [
                      for (final l in dayLabels)
                        SizedBox(
                          height: cell + gap,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              l,
                              style: const TextStyle(
                                color: TempusColors.textMuted,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                for (var w = 0; w < widget.weeks; w++)
                  Padding(
                    padding: const EdgeInsets.only(left: gap),
                    child: Column(
                      children: [
                        for (var d = 0; d < 7; d++)
                          _buildCell(
                            firstMonday.add(Duration(days: w * 7 + d)),
                            today,
                            cell,
                            gap,
                          ),
                      ],
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    key: ValueKey(selected),
                    selected == null
                        ? 'Melhor dia: ${formatMinutes(best)}'
                        : '${selected.day} ${kMonthsShort[selected.month - 1]} · ${selectedMinutes > 0 ? formatMinutes(selectedMinutes) : 'sem estudo'}',
                    style: const TextStyle(
                      color: TempusColors.textSub,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Text('Menos',
                  style: TextStyle(
                      color: TempusColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 5),
              for (var l = 0; l < 5; l++)
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    color: _color(l),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              const SizedBox(width: 2),
              const Text('Mais',
                  style: TextStyle(
                      color: TempusColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCell(DateTime day, DateTime today, double size, double gap) {
    final future = day.isAfter(today);
    final minutes = widget.minutesByDay[day] ?? 0;
    final isToday = day == today;
    final isSelected = day == _selected;

    return Padding(
      padding: EdgeInsets.only(bottom: gap),
      child: GestureDetector(
        onTap: future
            ? null
            : () => setState(() => _selected = isSelected ? null : day),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: future ? Colors.transparent : _color(_level(minutes)),
            borderRadius: BorderRadius.circular(size * 0.28),
            border: isSelected
                ? Border.all(color: Colors.white, width: 1.5)
                : isToday
                    ? Border.all(
                        color: TempusColors.accentSoft.withValues(alpha: 0.8),
                        width: 1.2)
                    : null,
          ),
        ),
      ),
    );
  }
}
