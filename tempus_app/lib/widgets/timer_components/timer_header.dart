import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class TimerHeader extends StatelessWidget {
  const TimerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Stack( // CORREÇÃO: Substituído Column por Stack
        children: [
          // Título 'Timer'
          Positioned(
            left: 0,
            right: 0,
            top: 10, // Posição vertical ajustada
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
                    'Timer',
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
          
          // Subtítulo 'Organize seus estudos...'
          Positioned(
            left: 0,
            right: 0,
            top: 66, // 10 (título) + 36 (altura do título) + ~20 (espaço)
            child: SizedBox(
              height: 48,
              child: Center(
                child: AutoSizeText(
                  'Organize seus estudos com o método Pomodoro',
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
          
          // Container 'Sistema Pomodoro Ativo'
          Positioned(
            left: 0,
            right: 0,
            top: 134, // 66 (subtítulo) + 48 (altura do subtítulo) + ~20 (espaço)
            child: Center(
              child: Container(
                width: 250,
                height: 50,
                decoration: ShapeDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(0.00, 0.50),
                    end: Alignment(1.00, 0.50),
                    colors: [
                      Color(0x19AC46FF),
                      Color(0x192B7FFF),
                      Color(0x19F6329A),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0x19FFFEFE)),
                    borderRadius: BorderRadius.circular(33554400),
                  ),
                ),
                child: Stack( // O Stack interno está correto para o ícone/texto
                  children: [
                    Positioned(
                      left: 15,
                      top: 20,
                      child: Opacity(
                        opacity: 0.57,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF05DF72),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(33554400),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: 300,
                        height: 24,
                        child: Center(
                          child: AutoSizeText(
                            'Sistema Pomodoro Ativo',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            minFontSize: 10,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}