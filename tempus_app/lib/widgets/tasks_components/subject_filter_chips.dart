import 'package:flutter/material.dart';
import '../../models/subject.dart';
import '../../theme/app_theme.dart';

class SubjectFilterChips extends StatelessWidget {
  final List<Subject> subjects;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const SubjectFilterChips({
    super.key,
    required this.subjects,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: [
          _Chip(
            label: 'Todas',
            color: TempusColors.accent,
            isSelected: selectedId == null,
            onTap: () => onChanged(null),
          ),
          ...subjects.map(
            (s) => _Chip(
              label: s.name,
              color: Color(s.colorValue),
              isSelected: selectedId == s.id,
              onTap: () => onChanged(selectedId == s.id ? null : s.id),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : TempusColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.6) : TempusColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : TempusColors.textSub,
                fontSize: 13,
                fontFamily: 'Arimo',
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
