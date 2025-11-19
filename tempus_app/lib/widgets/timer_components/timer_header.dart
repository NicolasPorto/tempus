import 'package:flutter/material.dart';

class TimerHeader extends StatelessWidget {
  const TimerHeader({super.key});

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
                    side: const BorderSide(width: 1, color: Color(0x19FFFEFE)),
                    borderRadius: BorderRadius.circular(33554400),
                  ),
                ),
                child: Stack(
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
                    const Center(
                      child: SizedBox(
                        width: 300,
                        height: 24,
                        child: Center(
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
          const Positioned(
            left: 0,
            right: 0,
            top: 114,
            child: SizedBox(
              height: 48,
              child: Center(
                child: Text(
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
    );
  }
}
