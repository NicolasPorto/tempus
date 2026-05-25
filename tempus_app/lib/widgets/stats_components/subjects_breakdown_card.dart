import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/subject.dart';
import '../../theme/app_theme.dart';

class SubjectsBreakdownCard extends StatefulWidget {
  final Map<String, int> minutesBySubjectId;
  final List<Subject> allSubjects;
  final Map<String, int> goalMinutesBySubjectId;
  final void Function(String subjectId, int goalMinutes)? onSetGoal;

  const SubjectsBreakdownCard({
    super.key,
    required this.minutesBySubjectId,
    required this.allSubjects,
    this.goalMinutesBySubjectId = const {},
    this.onSetGoal,
  });

  @override
  State<SubjectsBreakdownCard> createState() => _SubjectsBreakdownCardState();
}

class _SubjectsBreakdownCardState extends State<SubjectsBreakdownCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<CurvedAnimation> _entryAnims;
  late List<MapEntry<String, int>> _sortedEntries;
  late int _peak;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _prepareSortedData();
    _entryAnims = _buildEntryAnims();
    Future.microtask(() => _ctrl.forward());
  }

  void _prepareSortedData() {
    _sortedEntries = widget.minutesBySubjectId.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    _peak = _sortedEntries.isEmpty
        ? 1
        : _sortedEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
  }

  List<CurvedAnimation> _buildEntryAnims() {
    final n = _sortedEntries.length;
    return List.generate(n, (i) {
      final delay = n > 0 ? i / n * 0.5 : 0.0;
      return CurvedAnimation(
        parent: _ctrl,
        curve: Interval(
          delay.clamp(0.0, 1.0),
          (delay + 0.6).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      );
    });
  }

  @override
  void dispose() {
    for (final a in _entryAnims) {
      a.dispose();
    }
    _ctrl.dispose();
    super.dispose();
  }

  String _fmt(int minutes) {
    if (minutes < 60) return '${minutes}min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}h ${m}min' : '${h}h';
  }

  void _showGoalDialog(
      BuildContext context, Subject subj, int currentGoal) {
    HapticFeedback.selectionClick();
    int selected = currentGoal > 0 ? currentGoal : 60;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          backgroundColor: TempusColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: TempusColors.border),
          ),
          title: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Color(subj.colorValue),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Meta — ${subj.name}',
                  style: const TextStyle(
                    color: TempusColors.text,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Quanto quer estudar esta matéria por semana?',
                style: TextStyle(
                  color: TempusColors.textSub,
                  fontFamily: 'Arimo',
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                selected < 60
                    ? '$selected min'
                    : '${selected ~/ 60}h${selected % 60 > 0 ? ' ${selected % 60}min' : ''}',
                style: const TextStyle(
                  color: TempusColors.text,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  letterSpacing: -0.5,
                ),
              ),
              Slider(
                value: selected.toDouble(),
                min: 15,
                max: 480,
                divisions: 31,
                activeColor: Color(subj.colorValue),
                inactiveColor: TempusColors.border,
                onChanged: (v) => setDialog(() => selected = v.round()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('15 min',
                      style: TextStyle(
                          color: TempusColors.textSub,
                          fontSize: 11,
                          fontFamily: 'Arimo')),
                  Text('8h',
                      style: TextStyle(
                          color: TempusColors.textSub,
                          fontSize: 11,
                          fontFamily: 'Arimo')),
                ],
              ),
            ],
          ),
          actions: [
            if (currentGoal > 0)
              TextButton(
                onPressed: () {
                  widget.onSetGoal?.call(subj.id, 0);
                  Navigator.pop(ctx);
                },
                child: const Text('Remover',
                    style: TextStyle(
                        color: TempusColors.red, fontFamily: 'Arimo')),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar',
                  style: TextStyle(
                      color: TempusColors.textSub, fontFamily: 'Arimo')),
            ),
            TextButton(
              onPressed: () {
                widget.onSetGoal?.call(subj.id, selected);
                Navigator.pop(ctx);
              },
              child: const Text('Salvar',
                  style: TextStyle(
                      color: TempusColors.accent,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            // Accent bar
            Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: TempusColors.gradientDiag,
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
                            colors: [
                              TempusColors.accent.withValues(alpha: 0.15),
                              TempusColors.accentBlue.withValues(alpha: 0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: TempusColors.accent.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: TempusColors.accent,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Por Matéria',
                        style: TextStyle(
                          color: TempusColors.textSub,
                          fontSize: 13,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (_sortedEntries.isEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Nenhuma sessão registrada ainda.',
                      style: TextStyle(
                        color: TempusColors.textSub,
                        fontSize: 13,
                        fontFamily: 'Arimo',
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 20),
                    ...List.generate(_sortedEntries.length, (i) {
                      final e = _sortedEntries[i];
                      final subj = widget.allSubjects.firstWhere(
                        (s) => s.id == e.key,
                        orElse: () => Subject(
                          id: e.key,
                          name: 'Matéria',
                          colorValue: TempusColors.accent.toARGB32(),
                        ),
                      );
                      final color = Color(subj.colorValue);
                      final goalMinutes =
                          widget.goalMinutesBySubjectId[e.key] ?? 0;
                      final hasGoal = goalMinutes > 0;
                      final goalReached = hasGoal && e.value >= goalMinutes;
                      final ratio = hasGoal
                          ? (e.value / goalMinutes).clamp(0.0, 1.0)
                          : (_peak > 0 ? e.value / _peak : 0.0);
                      final barColor =
                          goalReached ? TempusColors.green : color;
                      final anim = _entryAnims[i];

                      return GestureDetector(
                        onTap: widget.onSetGoal == null
                            ? null
                            : () => _showGoalDialog(context, subj, goalMinutes),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        subj.name,
                                        style: const TextStyle(
                                          color: TempusColors.text,
                                          fontSize: 13,
                                          fontFamily: 'Arimo',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (goalReached) ...[
                                        const SizedBox(width: 6),
                                        const Icon(Icons.check_circle_rounded,
                                            color: TempusColors.green,
                                            size: 13),
                                      ],
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        hasGoal
                                            ? '${_fmt(e.value)} / ${_fmt(goalMinutes)}'
                                            : _fmt(e.value),
                                        style: const TextStyle(
                                          color: TempusColors.textSub,
                                          fontSize: 12,
                                          fontFamily: 'Arimo',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      if (widget.onSetGoal != null) ...[
                                        const SizedBox(width: 6),
                                        Icon(
                                          hasGoal
                                              ? Icons.flag_rounded
                                              : Icons.flag_outlined,
                                          color: hasGoal
                                              ? TempusColors.accent
                                              : TempusColors.textMuted,
                                          size: 13,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              AnimatedBuilder(
                                animation: anim,
                                builder: (_, __) => ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: ratio * anim.value,
                                    backgroundColor: TempusColors.surfaceHigh,
                                    valueColor:
                                        AlwaysStoppedAnimation(barColor),
                                    minHeight: 5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    if (widget.onSetGoal != null)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.touch_app_rounded,
                                color: TempusColors.textMuted, size: 11),
                            SizedBox(width: 4),
                            Text(
                              'Toque para definir meta por matéria',
                              style: TextStyle(
                                color: TempusColors.textMuted,
                                fontSize: 11,
                                fontFamily: 'Arimo',
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
