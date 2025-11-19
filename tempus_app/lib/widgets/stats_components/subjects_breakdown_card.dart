import 'package:flutter/material.dart';
import '../../models/subject.dart';

class SubjectsBreakdownCard extends StatelessWidget {
  final Map<String, int> minutesBySubjectId;
  final List<Subject> allSubjects;

  const SubjectsBreakdownCard({
    super.key,
    required this.minutesBySubjectId,
    required this.allSubjects,
  });

  @override
  Widget build(BuildContext context) {
    final subjectStats = minutesBySubjectId.entries.map((entry) {
      final subj = allSubjects.firstWhere(
        (x) => x.id == entry.key,
        orElse: () => allSubjects.first,
      );
      return {
        'name': subj.name,
        'minutes': entry.value,
        'color': Color(subj.colorValue),
      };
    }).toList();

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
        mainAxisSize: MainAxisSize.min,
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
                    colors: [Color(0x192B7FFF), Color(0x19AC46FF)],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.book,
                    color: Colors.purpleAccent.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Matérias',
                style: TextStyle(
                  color: Color(0xFFF4F4F4),
                  fontSize: 16,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (subjectStats.isEmpty)
            const Text(
              "Nenhuma sessão registrada ainda.",
              style: TextStyle(color: Color(0xFFA0A0A0)),
            ),
          ...subjectStats.map((s) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  CircleAvatar(radius: 8, backgroundColor: s['color'] as Color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s['name'] as String,
                      style: const TextStyle(
                        color: Color(0xFFF4F4F4),
                        fontSize: 16,
                        fontFamily: 'Arimo',
                      ),
                    ),
                  ),
                  Text(
                    '${s['minutes']} min',
                    style: const TextStyle(
                      color: Color(0xFFA0A0A0),
                      fontSize: 16,
                      fontFamily: 'Arimo',
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}