import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class TasksHeader extends StatelessWidget {
  const TasksHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 162,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 10,
            child: SizedBox(
              height: 36,
              child: Center(
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      colors: [Color(0xFFAC46FF), Color(0xFF2B7FFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: const AutoSizeText(
                    'Tarefas',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            top: 66,
            child: SizedBox(
              height: 48,
              child: Center(
                child: AutoSizeText(
                  'Crie e gerencie suas tarefas para manter-se organizado e produtivo.',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  minFontSize: 12,
                  style: const TextStyle(
                    color: Color(0xFFA0A0A0),
                    fontSize: 16,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
