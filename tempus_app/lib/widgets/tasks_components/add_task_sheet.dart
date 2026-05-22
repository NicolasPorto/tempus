import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/subject.dart';
import '../../theme/app_theme.dart';

class AddTaskSheet extends StatefulWidget {
  final List<Subject> subjects;
  final String initialSubjectId;
  final Future<bool> Function(String title, String subjectId, int minutes) onAdd;

  const AddTaskSheet({
    super.key,
    required this.subjects,
    required this.initialSubjectId,
    required this.onAdd,
  });

  static Future<void> show(
    BuildContext context, {
    required List<Subject> subjects,
    required String initialSubjectId,
    required Future<bool> Function(String, String, int) onAdd,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskSheet(
        subjects: subjects,
        initialSubjectId: initialSubjectId,
        onAdd: onAdd,
      ),
    );
  }

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final TextEditingController _ctrl = TextEditingController();
  late String _selectedSubjectId;
  int _selectedMinutes = 25;
  bool _isSaving = false;

  static const _durations = [25, 50, 90, 120];

  @override
  void initState() {
    super.initState();
    _selectedSubjectId =
        widget.subjects.any((s) => s.id == widget.initialSubjectId)
            ? widget.initialSubjectId
            : (widget.subjects.isNotEmpty ? widget.subjects.first.id : '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _selectedSubjectId.isEmpty) return;

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    final ok = await widget.onAdd(text, _selectedSubjectId, _selectedMinutes);
    if (ok && mounted) {
      Navigator.of(context).pop();
    } else if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: TempusColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: TempusColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: TempusColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (b) =>
                          TempusColors.gradient.createShader(b),
                      child: const Icon(
                        Icons.add_task_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Nova Tarefa',
                      style: TextStyle(
                        color: TempusColors.text,
                        fontSize: 17,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _sectionLabel('Título'),
                const SizedBox(height: 8),
                TextField(
                  controller: _ctrl,
                  autofocus: true,
                  cursorColor: TempusColors.accent,
                  style: const TextStyle(
                    color: TempusColors.text,
                    fontSize: 15,
                    fontFamily: 'Arimo',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ex: Resolver exercícios de cálculo...',
                    hintStyle: const TextStyle(
                      color: TempusColors.textMuted,
                      fontSize: 14,
                      fontFamily: 'Arimo',
                    ),
                    filled: true,
                    fillColor: TempusColors.surfaceHigh,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: TempusColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: TempusColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: TempusColors.accent, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                  onSubmitted: (_) => _submit(),
                ),

                const SizedBox(height: 18),

                _sectionLabel('Duração estimada'),
                const SizedBox(height: 8),
                Row(
                  children: _durations.map((min) {
                    final isSelected = _selectedMinutes == min;
                    final isLast = min == _durations.last;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedMinutes = min),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: EdgeInsets.only(right: isLast ? 0 : 8),
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? TempusColors.accent.withOpacity(0.15)
                                : TempusColors.surfaceHigh,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? TempusColors.accent.withOpacity(0.6)
                                  : TempusColors.border,
                            ),
                          ),
                          child: Text(
                            '${min}m',
                            style: TextStyle(
                              color: isSelected
                                  ? TempusColors.accent
                                  : TempusColors.textSub,
                              fontSize: 13,
                              fontFamily: 'Arimo',
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 18),

                _sectionLabel('Matéria'),
                const SizedBox(height: 8),
                if (widget.subjects.isEmpty)
                  const Text(
                    'Nenhuma matéria criada. Adicione uma matéria primeiro.',
                    style: TextStyle(
                      color: TempusColors.textMuted,
                      fontFamily: 'Arimo',
                      fontSize: 13,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.subjects.map((s) {
                      final isSelected = _selectedSubjectId == s.id;
                      final color = Color(s.colorValue);
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedSubjectId = s.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withOpacity(0.15)
                                : TempusColors.surfaceHigh,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? color.withOpacity(0.7)
                                  : TempusColors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 7),
                              Text(
                                s.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? color
                                      : TempusColors.textSub,
                                  fontSize: 13,
                                  fontFamily: 'Arimo',
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 24),

                GestureDetector(
                  onTap: _isSaving ? null : _submit,
                  child: AnimatedOpacity(
                    opacity: _isSaving ? 0.65 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: TempusColors.gradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: TempusColors.accent.withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_rounded,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Adicionar Tarefa',
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: TempusColors.textSub,
          fontSize: 11,
          fontFamily: 'Arimo',
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      );
}
