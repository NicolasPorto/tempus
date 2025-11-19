import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';

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
          AutoSizeText(
            hasSubjects ? 'Sem tarefas.' : 'Adicione matérias primeiro',
            maxLines: 1,
            minFontSize: 12,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF737373), fontSize: 16),
          ),
          const SizedBox(height: 4),
          AutoSizeText(
            hasSubjects
                ? 'Adicione tarefas no cartão acima.'
                : 'Você precisa ter pelo menos uma matéria ativa para adicionar tarefas.',
            maxLines: 2,
            minFontSize: 10,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF525252), fontSize: 14),
          ),
        ],
      ),
    );
  }
}