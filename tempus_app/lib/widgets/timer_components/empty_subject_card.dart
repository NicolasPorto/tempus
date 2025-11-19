import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class EmptySubjectCard extends StatelessWidget {
  final VoidCallback onCreateTap;

  const EmptySubjectCard({super.key, required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.00, 0.00),
          end: Alignment(1.00, 1.00),
          colors: [Color(0x7F171717), Color(0x7F0A0A0A)],
        ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x19FFFEFE)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            right: 0,
            top: 25,
            child: Center(
              child: Icon(Icons.book, color: Color(0xFFD4D4D4), size: 32),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 69,
            child: Center(
              child: AutoSizeText(
                'Adicione uma matéria para começar',
                textAlign: TextAlign.center,
                maxLines: 1,
                minFontSize: 12,
                style: const TextStyle(
                  color: Color(0xFFD4D4D4),
                  fontSize: 16,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 109,
            child: Center(
              child: GestureDetector(
                onTap: onCreateTap,
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
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Flexible(
                        child: AutoSizeText(
                          'Criar Matéria',
                          maxLines: 1,
                          minFontSize: 10,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                          ),
                        ),
                      ),
                    ],
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
