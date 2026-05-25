import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EmptySubjectCard extends StatefulWidget {
  final VoidCallback onCreateTap;

  const EmptySubjectCard({super.key, required this.onCreateTap});

  @override
  State<EmptySubjectCard> createState() => _EmptySubjectCardState();
}

class _EmptySubjectCardState extends State<EmptySubjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    Future.microtask(() => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: TempusColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: TempusColors.accent.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TempusColors.accent.withValues(alpha: 0.15),
                      TempusColors.accentBlue.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: TempusColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: TempusColors.accent,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Comece organizando seus estudos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TempusColors.text,
                  fontSize: 17,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Crie matérias como Matemática, Física ou Inglês para começar a registrar seu tempo de estudo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TempusColors.textSub,
                  fontSize: 13,
                  fontFamily: 'Arimo',
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: widget.onCreateTap,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: TempusColors.gradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: TempusColors.accent.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Criar Primeira Matéria',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
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
    );
  }
}
