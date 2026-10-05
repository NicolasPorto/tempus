import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tempus_app/models/subject.dart';
import '../../theme/app_theme.dart';

class SubjectSelector extends StatelessWidget {
  final List<Subject> subjects;
  final Subject? selectedSubject;
  final bool isLoading;
  final ValueChanged<Subject?> onSubjectChanged;
  final VoidCallback onManageTap;

  const SubjectSelector({
    super.key,
    required this.subjects,
    required this.selectedSubject,
    required this.isLoading,
    required this.onSubjectChanged,
    required this.onManageTap,
  });

  void _showSubjectSheet(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SubjectBottomSheet(
        subjects: subjects,
        selectedSubject: selectedSubject,
        onSubjectSelected: (s) {
          onSubjectChanged(s);
          Navigator.pop(context);
        },
        onManageTap: () {
          Navigator.pop(context);
          onManageTap();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSubject = selectedSubject != null;
    final subjectColor = hasSubject
        ? Color(selectedSubject!.colorValue)
        : TempusColors.textSub;

    return Semantics(
      button: true,
      label: 'Matéria: ${selectedSubject?.name ?? 'nenhuma'}',
      child: GestureDetector(
        onTap: isLoading
            ? null
            : subjects.isNotEmpty
                ? () => _showSubjectSheet(context)
                : onManageTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: TempusColors.surface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(TempusRadius.lg),
            border: Border.all(
              color: hasSubject
                  ? subjectColor.withValues(alpha: 0.35)
                  : TempusColors.border,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: subjectColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: TempusColors.accent,
                          ),
                        )
                      : Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: subjectColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: subjectColor.withValues(alpha: 0.6),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ESTUDANDO',
                      style: TextStyle(
                        color: TempusColors.textSub,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isLoading
                          ? 'Carregando…'
                          : hasSubject
                              ? selectedSubject!.name
                              : 'Selecione a matéria',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasSubject
                            ? TempusColors.text
                            : TempusColors.textSub,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: TempusColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.unfold_more_rounded,
                  color: TempusColors.textSub,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectBottomSheet extends StatelessWidget {
  final List<Subject> subjects;
  final Subject? selectedSubject;
  final ValueChanged<Subject> onSubjectSelected;
  final VoidCallback onManageTap;

  const _SubjectBottomSheet({
    required this.subjects,
    required this.selectedSubject,
    required this.onSubjectSelected,
    required this.onManageTap,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.75,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: TempusColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: TempusColors.border),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: TempusColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Matéria',
                      style: TextStyle(
                        color: TempusColors.text,
                        fontSize: 17,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: onManageTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: TempusColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: TempusColors.border),
                        ),
                        child: const Text(
                          'Gerenciar',
                          style: TextStyle(
                            color: TempusColors.textSub,
                            fontSize: 12,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  itemCount: subjects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final s = subjects[i];
                    final isSelected = s == selectedSubject;
                    final color = Color(s.colorValue);
                    return GestureDetector(
                      onTap: () => onSubjectSelected(s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.10)
                              : TempusColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? color.withValues(alpha: 0.4)
                                : TempusColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                s.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? TempusColors.text
                                      : TempusColors.textSub,
                                  fontSize: 15,
                                  fontFamily: 'Manrope',
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_rounded,
                                color: color,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
