import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/task.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TasksScreenContent();
  }
}

class _TasksScreenContent extends StatefulWidget {
  const _TasksScreenContent();

  @override
  State<_TasksScreenContent> createState() => _TasksScreenContentState();
}

class _TasksScreenContentState extends State<_TasksScreenContent> {
  final store = StorageService.instance;
  final TextEditingController _ctrl = TextEditingController();
  String selectedSubjectId = '';

  @override
  void initState() {
    super.initState();
    if (store.subjects.isNotEmpty) {
      selectedSubjectId = store.subjects.first.id;
    }
  }

  void _addTask() async {
    if (store.subjects.isEmpty) return;

    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    final t = TaskItem(title: text, subjectId: selectedSubjectId);
    await store.addTask(t);
    _ctrl.clear();
    setState(() {});
  }

  Widget _buildTasks() {
    if (store.tasks.isEmpty || store.subjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: ShapeDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.00, 0.00),
                  end: Alignment(1.00, 1.00),
                  colors: [const Color(0x19AC46FF), const Color(0x192B7FFF)],
                ),
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: const Color(0x19FFFEFE)),
                  borderRadius: BorderRadius.circular(33554400),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 20,
                    top: 20,
                    child: Container(
                      width: 40,
                      height: 40,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(),
                      child: Stack(
                        children: [
                          SizedBox(
                            child: SvgPicture.asset(
                              'lib/assets/icons/icon_tasks.svg',
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              store.tasks.isEmpty
                  ? 'Sem tarefas.'
                  : 'Adicione matérias primeiro',
              style: TextStyle(color: Color(0xFF737373), fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              store.tasks.isEmpty
                  ? 'Adicione matérias no cartão acima.'
                  : 'Adicione matérias na aba "Timer".',
              style: TextStyle(color: Color(0xFF737373), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: store.tasks.length,
      itemBuilder: (context, i) {
        final t = store.tasks[i];
        final subj = store.subjects.firstWhere(
          (s) => s.id == t.subjectId,
          orElse: () => store.subjects.first,
        );
        return Card(
          color: const Color(0x7F171717), 
          margin: const EdgeInsets.only(
            bottom: 8,
          ), 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(width: 1, color: Color(0x19FFFEFE)),
          ),
          child: ListTile(
            leading: Checkbox(
              value: t.done,
              onChanged: (_) async {
                await store.toggleTask(t.id);
                setState(() {});
              },
              activeColor: Color(
                subj.colorValue,
              ), // Cor do checkbox usando a cor da matéria
              checkColor: Colors.white,
            ),
            title: Text(
              t.title,
              style: TextStyle(
                decoration: t.done ? TextDecoration.lineThrough : null,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              subj.name,
              style: TextStyle(
                color: Color(subj.colorValue), // Nome da matéria com sua cor
                fontSize: 12,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFD4D4D4)),
              onPressed: () async {
                await store.removeTask(t.id);
                setState(() {});
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSubjectSelected = store.subjects.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 162,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 66,
                  child: SizedBox(
                    height: 36,
                    child: Center(
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            colors: [Color(0xFFAC46FF), Color(0xFF2B7FFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: const Text(
                          'Tarefas',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 114,
                  child: SizedBox(
                    height: 48,
                    child: Center(
                      child: const Text(
                        'Crie e gerencie suas tarefas para manter-se organizado e produtivo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFA0A0A0),
                          fontSize: 16,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 50),
          Stack(
            // Altura total do cartão (370) + Altura da linha de gradiente (4)
            // Como a linha se sobrepõe, vamos manter a altura original de 370 ou ajustá-la.
            // Vamos usar 374 (370 + 4) ou usar um Container pai para controlar a altura se necessário.
            children: [
              // 1. O CORPO DO CARTÃO (Container Maior)
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
                  // Remova a borda "side" que estava na borda superior
                  shape: RoundedRectangleBorder(
                    // Mantém as bordas arredondadas
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
                      // ... (Restante do conteúdo do cartão, sem precisar mudar)
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
                      Column(
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
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0x19FFFEFE),
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: TextField(
                              controller: _ctrl,
                              cursorColor: isSubjectSelected
                                  ? Color(
                                      store.subjects
                                          .firstWhere(
                                            (s) => s.id == selectedSubjectId,
                                            orElse: () => store.subjects.first,
                                          )
                                          .colorValue,
                                    )
                                  : const Color(0xFFD4D4D4),
                              style: const TextStyle(
                                color: Color(0xFFF4F4F4),
                                fontSize: 16,
                                fontFamily: 'Arimo',
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                hintText:
                                    'Ex: Resolver exercícios do capítulo 5...',
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
                      ),
                      const SizedBox(height: 24),

                      Column(
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
                              color: store.subjects.isEmpty
                                  ? const Color(0x40171717)
                                  : const Color(0x7F171717),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: store.subjects.isEmpty
                                      ? const Color(0x19FFFEFE).withOpacity(0.5)
                                      : const Color(0x19FFFEFE),
                                ),
                                borderRadius: BorderRadius.circular(
                                  14,
                                ), // formato "pílula"
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: isSubjectSelected
                                    ? selectedSubjectId
                                    : null,
                                icon: Opacity(
                                  opacity: store.subjects.isEmpty ? 0.2 : 0.50,
                                  child: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Color(0xFFD4D4D4),
                                  ),
                                ),
                                dropdownColor: const Color.fromARGB(
                                  202,
                                  23,
                                  23,
                                  23,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                isExpanded: true,

                                onChanged: store.subjects.isEmpty
                                    ? null
                                    : (String? newValue) {
                                        setState(() {
                                          selectedSubjectId =
                                              newValue ?? selectedSubjectId;
                                        });
                                      },

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

                                items: store.subjects.map((s) {
                                  final isSelected = s.id == selectedSubjectId;

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

                                  return DropdownMenuItem<String>(
                                    value: s.id,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          margin: const EdgeInsets.only(
                                            right: 8,
                                          ),
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
                                  return store.subjects.map<Widget>((s) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (isSubjectSelected)
                                          Row(
                                            children: [
                                              Container(
                                                width: 10,
                                                height: 10,
                                                margin: const EdgeInsets.only(
                                                  right: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Color(
                                                    store.subjects
                                                        .firstWhere(
                                                          (x) =>
                                                              x.id ==
                                                              selectedSubjectId,
                                                        )
                                                        .colorValue,
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              Text(
                                                store.subjects
                                                    .firstWhere(
                                                      (x) =>
                                                          x.id ==
                                                          selectedSubjectId,
                                                    )
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
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: isSubjectSelected ? _addTask : null,
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
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  // Aplica o arredondamento APENAS para os cantos superiores
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 4, // Altura da linha de gradiente
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
          ),
          const SizedBox(height: 32),
          _buildTasks(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
