import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EmptyTasksView extends StatefulWidget {
  final bool hasSubjects;
  final VoidCallback? onManageSubjects;

  const EmptyTasksView({
    super.key,
    required this.hasSubjects,
    this.onManageSubjects,
  });

  @override
  State<EmptyTasksView> createState() => _EmptyTasksViewState();
}

class _EmptyTasksViewState extends State<EmptyTasksView>
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
      begin: const Offset(0, 0.06),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TempusColors.accent.withValues(alpha: 0.12),
                      TempusColors.accentBlue.withValues(alpha: 0.07),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: TempusColors.accent.withValues(alpha: 0.25),
                  ),
                ),
                child: Center(
                  child: Icon(
                    widget.hasSubjects
                        ? Icons.task_alt_rounded
                        : Icons.menu_book_rounded,
                    color: TempusColors.accent,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.hasSubjects
                    ? 'Nenhuma tarefa ainda'
                    : 'Crie uma matéria primeiro',
                style: const TextStyle(
                  color: TempusColors.text,
                  fontSize: 17,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.hasSubjects
                    ? 'Toque no + para adicionar sua próxima tarefa de estudo.'
                    : 'Organize seus estudos criando matérias como Matemática, Física ou Inglês.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: TempusColors.textSub,
                  fontSize: 13,
                  fontFamily: 'Arimo',
                  height: 1.55,
                ),
              ),
              if (!widget.hasSubjects && widget.onManageSubjects != null) ...[
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: widget.onManageSubjects,
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
                          'Criar Matéria',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
