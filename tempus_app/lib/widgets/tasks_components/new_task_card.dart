import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tempus_app/models/subject.dart';

class NewTaskCard extends StatelessWidget {
  final TextEditingController controller;
  final List<Subject> subjects;
  final String selectedSubjectId;
  final ValueChanged<String?> onSubjectChanged;
  final VoidCallback onAddTask;

  const NewTaskCard({
    super.key,
    required this.controller,
    required this.subjects,
    required this.selectedSubjectId,
    required this.onSubjectChanged,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final isSubjectSelected = subjects.isNotEmpty;
    
    final selectedSubject = subjects.firstWhere(
        (s) => s.id == selectedSubjectId,
        orElse: () => subjects.isNotEmpty ? subjects.first : Subject(id: '', name: '', colorValue: 0xFFD4D4D4, categoryId: ''),
    );

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 370,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            gradient: const LinearGradient(
              begin: Alignment(0.00, 0.00),
              end: Alignment(1.00, 1.00),
              colors: [Color(0xCC171717), Color(0xCC0A0A0A)],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      'Nova Tarefa',
                      style: TextStyle(
                        color: Color(0xFFF4F4F4),
                        fontSize: 16,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildTitleInput(selectedSubject.colorValue, isSubjectSelected),
                const SizedBox(height: 24),
                _buildSubjectDropdown(),
                const SizedBox(height: 48),
                _buildAddButton(isSubjectSelected),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.00, 0.50),
                  end: Alignment(1.00, 0.50),
                  colors: [
                    Color(0xFFAC46FF),
                    Color(0xFF2B7FFF),
                    Color(0xFFF6329A),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleInput(int colorValue, bool isSubjectSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Título da Tarefa',
          style: TextStyle(
            color: Color(0xFFD4D4D4),
            fontSize: 14,
            fontFamily: 'Arimo',
            fontWeight: FontWeight.w400,
            height: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: ShapeDecoration(
            color: const Color(0x7F0A0A0A),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0x19FFFEFE)),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: TextField(
            controller: controller,
            cursorColor: isSubjectSelected
                ? Color(colorValue)
                : const Color(0xFFD4D4D4),
            style: const TextStyle(
              color: Color(0xFFF4F4F4),
              fontSize: 16,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              hintText: 'Ex: Resolver exercícios do capítulo 5...',
              hintStyle: TextStyle(
                color: Color(0xFF717182),
                fontSize: 16,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Matéria',
          style: TextStyle(
            color: Color(0xFFD4D4D4),
            fontSize: 14,
            fontFamily: 'Arimo',
            fontWeight: FontWeight.w400,
            height: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: ShapeDecoration(
            color: subjects.isEmpty
                ? const Color(0x40171717)
                : const Color(0x7F171717),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: subjects.isEmpty
                    ? const Color(0x19FFFEFE).withOpacity(0.5)
                    : const Color(0x19FFFEFE),
              ),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: subjects.any((s) => s.id == selectedSubjectId) ? selectedSubjectId : null,
              icon: Opacity(
                opacity: subjects.isEmpty ? 0.2 : 0.50,
                child: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFD4D4D4)),
              ),
              dropdownColor: const Color.fromARGB(202, 23, 23, 23),
              borderRadius: BorderRadius.circular(12),
              isExpanded: true,
              onChanged: subjects.isEmpty ? null : onSubjectChanged,
              hint: const Text(
                'Selecione a matéria...',
                style: TextStyle(
                  color: Color(0xFF717182),
                  fontSize: 14,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
              items: subjects.map((s) {
                final isSelected = s.id == selectedSubjectId;
                final textStyle = TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFFD4D4D4),
                  fontSize: 14,
                  fontFamily: 'Arimo',
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  height: 1.43,
                );

                return DropdownMenuItem<String>(
                  value: s.id,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Color(s.colorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(s.name, style: textStyle),
                    ],
                  ),
                );
              }).toList(),
              selectedItemBuilder: (BuildContext context) {
                return subjects.map<Widget>((s) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Color(
                                subjects
                                    .firstWhere((x) => x.id == selectedSubjectId, orElse: () => s)
                                    .colorValue,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            subjects
                                .firstWhere((x) => x.id == selectedSubjectId, orElse: () => s)
                                .name,
                            style: const TextStyle(
                              color: Color(0xFFF4F4F4),
                              fontSize: 14,
                              fontFamily: 'Arimo',
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                            ),
                          ),
                        ],
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
      child: Opacity(
        opacity: isSubjectSelected ? 1.0 : 0.50,
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: ShapeDecoration(
            gradient: const LinearGradient(
              begin: Alignment(0.00, 0.50),
              end: Alignment(1.00, 0.50),
              colors: [Color(0xFFAC46FF), Color(0xFF2B7FFF)],
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
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Adicionar Tarefa',
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
    );
  }
}