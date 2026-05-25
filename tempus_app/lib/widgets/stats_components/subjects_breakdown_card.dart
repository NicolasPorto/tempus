import 'package:flutter/material.dart';
import '../../models/subject.dart';
import '../../theme/app_theme.dart';

class SubjectsBreakdownCard extends StatefulWidget {
  final Map<String, int> minutesBySubjectId;
  final List<Subject> allSubjects;

  const SubjectsBreakdownCard({
    super.key,
    required this.minutesBySubjectId,
    required this.allSubjects,
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
                      final ratio = _peak > 0 ? e.value / _peak : 0.0;
                      final anim = _entryAnims[i]; // cached

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  ],
                                ),
                                Text(
                                  _fmt(e.value),
                                  style: const TextStyle(
                                    color: TempusColors.textSub,
                                    fontSize: 12,
                                    fontFamily: 'Arimo',
                                    fontWeight: FontWeight.w400,
                                  ),
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
                                      AlwaysStoppedAnimation(color),
                                  minHeight: 5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
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
