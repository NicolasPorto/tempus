import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/timer_painter.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Center(child: _FigmaDesignContent()),
    );
  }
}

class _FigmaDesignContent extends StatelessWidget {
  const _FigmaDesignContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 378),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            height: 162,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
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
                          side: const BorderSide(
                            width: 1,
                            color: Color(0x19FFFEFE),
                          ),
                          borderRadius: BorderRadius.circular(33554400),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 25,
                            top: 21,
                            child: Opacity(
                              opacity: 0.57,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: ShapeDecoration(
                                  color: const Color(0xFF05DF72),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      33554400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Positioned(
                            left: 45,
                            top: 13,
                            child: SizedBox(
                              width: 300,
                              height: 24,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    child: Text(
                                      'Sistema Pomodoro Ativo',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFFA0A0A0),
                                        fontSize: 16,
                                        fontFamily: 'Arimo',
                                        fontWeight: FontWeight.w400,
                                        height: 1.50,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  top: 66,
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
                        child: const Text(
                          'Estudo Focado',
                          textAlign: TextAlign.center,
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
                  top: 114,
                  child: SizedBox(
                    height: 48,
                    child: Center(
                      child: const Text(
                        'Organize seus estudos com o método Pomodoro',
                        textAlign: TextAlign.center,
                        style: TextStyle(
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
          const SizedBox(height: 48),
          Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 80,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 32,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: SvgPicture.asset(
                                    'lib/assets/icons/icon_star.svg',
                                    width: 16,
                                    height: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Selecione a matéria',
                                  style: TextStyle(
                                    color: Color(0xFFD4D4D4),
                                    fontSize: 16,
                                    fontFamily: 'Arimo',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 110.59,
                              height: 32,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),

                              child: Row(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: SvgPicture.asset(
                                          'lib/assets/icons/icon_plus.svg',
                                          width: 16,
                                          height: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Gerenciar',
                                        style: TextStyle(
                                          color: Color(0xFFA0A0A0),
                                          fontSize: 14,
                                          fontFamily: 'Arimo',
                                          fontWeight: FontWeight.w400,
                                          height: 1.43,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: ShapeDecoration(
                          color: const Color(0x7F171717),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1,
                              color: Color(0x19FFFEFE),
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Escolha uma matéria...',
                              style: TextStyle(
                                color: Color(0xFF717182),
                                fontSize: 14,
                                fontFamily: 'Arimo',
                                fontWeight: FontWeight.w400,
                                height: 1.43,
                              ),
                            ),
                            Opacity(
                              opacity: 0.50,
                              child: Container(
                                width: 16,
                                height: 16,
                                child: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Color(0xFF717182),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                Center(
                  // Centraliza o círculo na tela
                  child: Container(
                    width: 346, // Largura total do seu círculo
                    height: 346, // Altura total do seu círculo
                    decoration: ShapeDecoration(
                      // Decoração do card de fundo
                      gradient: const LinearGradient(
                        begin: Alignment(0.00, 0.00),
                        end: Alignment(1.00, 1.00),
                        colors: [Color(0xCC171717), Color(0xCC0A0A0A)],
                      ),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 2,
                          color: Color(0x19FFFEFE),
                        ),
                        borderRadius: BorderRadius.circular(
                          48,
                        ), // Borda do card (não do círculo principal)
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
                    child: Stack(
                      // Usamos um Stack para sobrepor o CustomPaint e os textos
                      alignment:
                          Alignment.center, // Centraliza os filhos do Stack
                      children: [
                        // O CustomPaint que desenha o círculo e os arcos
                        SizedBox(
                          width:
                              280, // Tamanho do círculo efetivo (um pouco menor que o container pai)
                          height: 280,
                          child: CustomPaint(
                            painter: TimerPainter(
                              backgroundColor: const Color(0xFF2C2C34),
                              progressColor: const Color(0xFF9042FF),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '25:00',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 80,
                                fontFamily: 'Arimo',
                                fontWeight: FontWeight.w400,
                                height: 1.20,
                                letterSpacing: -2.40,
                              ),
                            ),
                            SizedBox(height: 16),
                            Center(
                              child: ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (bounds) {
                                  return const LinearGradient(
                                    colors: [
                                      Color(0xFFAC46FF),
                                      Color(0xFF2B7FFF),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds);
                                },
                                child: Text(
                                  'Pressione para começar',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFFA0A0A0),
                                    fontSize: 16,
                                    fontFamily: 'Arimo',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 230,
                    height: 56,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Opacity(
                            opacity: 0.50,
                            child: Container(
                              height: 56,
                              decoration: ShapeDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment(0.00, 0.50),
                                  end: Alignment(1.00, 0.50),
                                  colors: [
                                    Color(0xFFAC46FF),
                                    Color(0xFF2B7FFF),
                                  ],
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                shadows: const [
                                  BoxShadow(
                                    color: Color(0x19000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 4),
                                    spreadRadius: -4,
                                  ),
                                  BoxShadow(
                                    color: Color(0x19000000),
                                    blurRadius: 15,
                                    offset: Offset(0, 10),
                                    spreadRadius: -3,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.play_arrow, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Iniciar Foco',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Arimo',
                                      fontWeight: FontWeight.w400,
                                      height: 1.43,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 56,
                          height: 56,
                          decoration: ShapeDecoration(
                            color: const Color(0x7F171717),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 2,
                                color: Color(0x19FFFEFE),
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 6,
                                offset: Offset(0, 4),
                                spreadRadius: -4,
                              ),
                              BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 15,
                                offset: Offset(0, 10),
                                spreadRadius: -3,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Color(0xFFD4D4D4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Card Adicione uma matéria
                Container(
                  width: double.infinity,
                  height: 170,
                  decoration: ShapeDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment(0.00, 0.00),
                      end: Alignment(1.00, 1.00),
                      colors: [Color(0x7F171717), Color(0x7F0A0A0A)],
                    ),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0x19FFFEFE),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Stack(
                    children: [
                      const Positioned(
                        left: 157,
                        top: 25,
                        child: Icon(
                          Icons.book,
                          color: Color(0xFFD4D4D4),
                          size: 32,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 69,
                        child: SizedBox(
                          height: 24,
                          child: Center(
                            child: const Text(
                              'Adicione uma matéria para começar',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFD4D4D4),
                                fontSize: 16,
                                fontFamily: 'Arimo',
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Botão Criar Matéria
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 109,
                        child: Center(
                          child: Container(
                            width: 138.69,
                            height: 36,
                            decoration: ShapeDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment(0.00, 0.50),
                                end: Alignment(1.00, 0.50),
                                colors: [Color(0xFFAC46FF), Color(0xFF2B7FFF)],
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add, color: Colors.white, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Criar Matéria',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Arimo',
                                    fontWeight: FontWeight.w400,
                                    height: 1.43,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
