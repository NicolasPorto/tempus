import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'lib/assets/icons/icon_star.svg',
                  width: 14,
                  height: 14,
                  colorFilter: const ColorFilter.mode(
                    TempusColors.textSub,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 7),
                const Text(
                  'Selecione a matéria',
                  style: TextStyle(
                    color: TempusColors.text,
                    fontSize: 14,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: onManageTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: TempusColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: TempusColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'lib/assets/icons/icon_plus.svg',
                      width: 12,
                      height: 12,
                      colorFilter: const ColorFilter.mode(
                        TempusColors.accent,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Gerenciar',
                      style: TextStyle(
                        color: TempusColors.textSub,
                        fontSize: 12,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        isLoading
            ? const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: TempusColors.accent,
                  ),
                ),
              )
            : Container(
                width: double.infinity,
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: subjects.isEmpty
                      ? TempusColors.surface.withOpacity(0.5)
                      : TempusColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TempusColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Subject>(
                    value: subjects.contains(selectedSubject)
                        ? selectedSubject
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
                    hint: const Text(
                      'Escolha uma matéria...',
                      style: TextStyle(
                        color: TempusColors.textSub,
                        fontSize: 14,
                        fontFamily: 'Arimo',
                      ),
                    ),
                    items: subjects.map((subject) {
                      final isSelected = subject == selectedSubject;
                      return DropdownMenuItem<Subject>(
                        value: subject,
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Color(subject.colorValue),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: AutoSizeText(
                                subject.name,
                                maxLines: 1,
                                minFontSize: 10,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isSelected
                                      ? TempusColors.text
                                      : const Color(0xFFCCCCCC),
                                  fontSize: 14,
                                  fontFamily: 'Arimo',
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    selectedItemBuilder: (context) {
                      return subjects.map<Widget>((item) {
                        return Row(
                          children: [
                            if (selectedSubject != null) ...[
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Color(selectedSubject!.colorValue),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: AutoSizeText(
                                  selectedSubject!.name,
                                  maxLines: 1,
                                  minFontSize: 10,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: TempusColors.text,
                                    fontSize: 14,
                                    fontFamily: 'Arimo',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
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
}
