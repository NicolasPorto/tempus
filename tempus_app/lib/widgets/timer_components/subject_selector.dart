import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tempus_app/models/subject.dart';

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
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 32,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                    const AutoSizeText(
                      'Selecione a matéria',
                      maxLines: 1,
                      minFontSize: 12,
                      style: TextStyle(
                        color: Color(0xFFD4D4D4),
                        fontSize: 16,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 110.59,
                  height: 32,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: onManageTap,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: SvgPicture.asset(
                            'lib/assets/icons/icon_plus.svg',
                            width: 16,
                            height: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Flexible(
                          child: AutoSizeText(
                            'Gerenciar',
                            maxLines: 1,
                            minFontSize: 10,
                            style: TextStyle(
                              color: Color(0xFFD4D4D4),
                              fontSize: 16,
                              fontFamily: 'Arimo',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : Container(
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
                    child: DropdownButton<Subject>(
                      value: selectedSubject,
                      icon: Opacity(
                        opacity: subjects.isEmpty ? 0.2 : 0.50,
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFFD4D4D4),
                        ),
                      ),
                      dropdownColor: const Color.fromARGB(202, 23, 23, 23),
                      borderRadius: BorderRadius.circular(12),
                      isExpanded: true,
                      onChanged: subjects.isEmpty ? null : onSubjectChanged,
                      hint: const AutoSizeText(
                        'Escolha uma matéria...',
                        maxLines: 1,
                        minFontSize: 10,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF717182),
                          fontSize: 14,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                      items: subjects.map((Subject subject) {
                        final isSelected = subject == selectedSubject;
                        final textStyle = TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFFD4D4D4),
                          fontSize: 14,
                          fontFamily: 'Arimo',
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          height: 1.43,
                        );

                        return DropdownMenuItem<Subject>(
                          value: subject,
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Color(subject.colorValue),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: AutoSizeText(
                                  subject.name,
                                  style: textStyle,
                                  maxLines: 1,
                                  minFontSize: 10,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      selectedItemBuilder: (BuildContext context) {
                        return subjects.map<Widget>((Subject item) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (selectedSubject != null)
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: Color(
                                            selectedSubject!.colorValue,
                                          ),
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
                                            color: Color(0xFFF4F4F4),
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
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
