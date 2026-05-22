import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:tempus_app/models/subject.dart';
import '../../theme/app_theme.dart';

class NewTaskCard extends StatelessWidget {
  final TextEditingController controller;
  final List<Subject> subjects;
  final String selectedSubjectId;
  final ValueChanged<String?> onSubjectChanged;
  final VoidCallback onAddTask;
  final int selectedHours;
  final ValueChanged<int> onHoursChanged;

  const NewTaskCard({
    super.key,
    required this.controller,
    required this.subjects,
    required this.selectedSubjectId,
    required this.onSubjectChanged,
    required this.onAddTask,
    required this.selectedHours,
    required this.onHoursChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSubjectSelected = subjects.isNotEmpty;

    final selectedSubject = subjects.firstWhere(
      (s) => s.id == selectedSubjectId,
      orElse: () => subjects.isNotEmpty
          ? subjects.first
          : Subject(id: '', name: '', colorValue: 0xFFA855F7, categoryId: ''),
    );

    final accentColor =
        isSubjectSelected ? Color(selectedSubject.colorValue) : TempusColors.accent;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: TempusColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TempusColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 32,
            offset: Offset(0, 12),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color accent bar at top
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor,
                  TempusColors.accentBlue,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.add_task_rounded,
                      color: TempusColors.accent,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Nova Tarefa',
                      style: TextStyle(
                        color: TempusColors.text,
                        fontSize: 16,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _buildTitleAndDurationInput(accentColor, isSubjectSelected),

                const SizedBox(height: 16),

                _buildSubjectDropdown(),

                const SizedBox(height: 20),

                _buildAddButton(isSubjectSelected),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndDurationInput(Color accentColor, bool isSubjectSelected) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Título',
                style: TextStyle(
                  color: TempusColors.textSub,
                  fontSize: 11,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: TempusColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TempusColors.border),
                ),
                child: TextField(
                  controller: controller,
                  cursorColor: accentColor,
                  style: const TextStyle(
                    color: TempusColors.text,
                    fontSize: 14,
                    fontFamily: 'Arimo',
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    hintText: 'Ex: Resolver exercícios...',
                    hintStyle: TextStyle(
                      color: TempusColors.textMuted,
                      fontSize: 14,
                      fontFamily: 'Arimo',
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Horas',
              style: TextStyle(
                color: TempusColors.textSub,
                fontSize: 11,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 52,
              height: 44,
              decoration: BoxDecoration(
                color: TempusColors.surfaceHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TempusColors.border),
              ),
              child: ListWheelScrollView.useDelegate(
                itemExtent: 28,
                perspective: 0.005,
                diameterRatio: 1.2,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: onHoursChanged,
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: 13,
                  builder: (context, index) {
                    final isSelected = index == selectedHours;
                    return Center(
                      child: Text(
                        '$index',
                        style: TextStyle(
                          fontFamily: 'Arimo',
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isSelected ? accentColor : TempusColors.textMuted,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubjectDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Matéria',
          style: TextStyle(
            color: TempusColors.textSub,
            fontSize: 11,
            fontFamily: 'Arimo',
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: subjects.isEmpty
                ? TempusColors.surfaceHigh.withOpacity(0.5)
                : TempusColors.surfaceHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TempusColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: subjects.any((s) => s.id == selectedSubjectId)
                  ? selectedSubjectId
                  : null,
              icon: Opacity(
                opacity: subjects.isEmpty ? 0.2 : 0.6,
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: TempusColors.textSub,
                ),
              ),
              dropdownColor: TempusColors.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
              isExpanded: true,
              onChanged: subjects.isEmpty ? null : onSubjectChanged,
              hint: Text(
                'Selecione uma matéria',
                style: TextStyle(
                  color: TempusColors.textMuted,
                  fontSize: 14,
                  fontFamily: 'Arimo',
                ),
              ),
              items: subjects.map((s) {
                final isSelected = s.id == selectedSubjectId;
                return DropdownMenuItem<String>(
                  value: s.id,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Color(s.colorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                      AutoSizeText(
                        s.name,
                        maxLines: 1,
                        minFontSize: 10,
                        style: TextStyle(
                          color: isSelected ? TempusColors.text : const Color(0xFFCCCCCC),
                          fontSize: 14,
                          fontFamily: 'Arimo',
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              selectedItemBuilder: (context) {
                return subjects.map<Widget>((s) {
                  final current = subjects.firstWhere(
                    (x) => x.id == selectedSubjectId,
                    orElse: () => s,
                  );
                  return Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Color(current.colorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                      AutoSizeText(
                        current.name,
                        maxLines: 1,
                        minFontSize: 10,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: TempusColors.text,
                          fontSize: 14,
                          fontFamily: 'Arimo',
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(bool isSubjectSelected) {
    return GestureDetector(
      onTap: isSubjectSelected ? onAddTask : null,
      child: AnimatedOpacity(
        opacity: isSubjectSelected ? 1.0 : 0.35,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: TempusColors.gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: TempusColors.accent.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text(
                'Adicionar Tarefa',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
