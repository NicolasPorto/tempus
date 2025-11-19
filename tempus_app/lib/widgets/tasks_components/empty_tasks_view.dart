import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyTasksView extends StatelessWidget {
  final bool hasSubjects;

  const EmptyTasksView({super.key, required this.hasSubjects});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: ShapeDecoration(
              gradient: const LinearGradient(
                begin: Alignment(0.00, 0.00),
                end: Alignment(1.00, 1.00),
                colors: [Color(0x19AC46FF), Color(0x192B7FFF)],
              ),
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Color(0x19FFFEFE)),
                borderRadius: BorderRadius.circular(33554400),
              ),
            ),
            child: Center(
              child: SizedBox(
                child: SvgPicture.asset(
                  'lib/assets/icons/icon_tasks.svg',
                  width: 50,
                  height: 50,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasSubjects ? 'Sem tarefas.' : 'Adicione matérias primeiro',
            style: const TextStyle(color: Color(0xFF737373), fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            hasSubjects
                ? 'Adicione tarefas no cartão acima.'
                : 'Adicione matérias na aba "Timer".',
            style: const TextStyle(color: Color(0xFF737373), fontSize: 14),
          ),
        ],
      ),
    );
  }
}