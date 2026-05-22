import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EmptySubjectCard extends StatelessWidget {
  final VoidCallback onCreateTap;

  const EmptySubjectCard({super.key, required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TempusColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TempusColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: TempusColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: TempusColors.accent.withOpacity(0.2)),
            ),
            child: const Center(
              child: Icon(
                Icons.menu_book_rounded,
                color: TempusColors.accent,
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Adicione uma matéria para começar',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TempusColors.textSub,
              fontSize: 14,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onCreateTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: TempusColors.gradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Criar Matéria',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
