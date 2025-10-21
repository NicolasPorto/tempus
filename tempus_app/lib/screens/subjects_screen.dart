import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/subject.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({Key? key}) : super(key: key);

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> with SingleTickerProviderStateMixin {
  final store = StorageService.instance;
  final TextEditingController _ctrl = TextEditingController();
  Color selectedColor = Colors.indigo;

  late AnimationController _controller;
  late Animation<Color?> _color1Animation;
  late Animation<Color?> _color2Animation;

 @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Aumentei a duração para uma transição mais suave e perceptível
    )..repeat(reverse: true);

    // Defina as cores de início, meio e fim para cada ponto do gradiente
    // Usaremos intervalos de animação (Interval) para fazer a transição entre 3 cores,
    // garantindo que a primeira metade da animação use as cores 1 e a segunda metade use as cores 2.

    // Sequência de cores para o PONTO 1 do gradiente: Roxo -> Azul -> Roxo (para o loop)
    _color1Animation = TweenSequence<Color?>([
      // 0.0 a 0.5: Roxo para Azul
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.purple.shade700, end: Colors.blue.shade700),
        weight: 1.0, // Peso igual para cada transição
      ),
      // 0.5 a 1.0: Azul para Roxo (voltando ao roxo, pois o controller vai reverter)
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.blue.shade700, end: Colors.purple.shade700),
        weight: 1.0,
      ),
    ]).animate(_controller);

    // Sequência de cores para o PONTO 2 do gradiente: Preto -> Roxo Escuro -> Preto (para o loop)
    _color2Animation = TweenSequence<Color?>([
      // 0.0 a 0.5: Preto para Roxo Escuro
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.black, end: Colors.purple.shade900),
        weight: 1.0,
      ),
      // 0.5 a 1.0: Roxo Escuro para Preto
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.purple.shade900, end: Colors.black),
        weight: 1.0,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _cycleColor() {
    final colors = [Colors.indigo, Colors.pink, Colors.green, Colors.orange, Colors.cyan, Colors.purple];
    final idx = colors.indexWhere((c) => c.value == selectedColor.value);
    setState(() => selectedColor = colors[(idx + 1) % colors.length]);
  }

  void _addSubject() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    final s = Subject(name: name, colorValue: selectedColor.value);
    await store.addSubject(s);
    _ctrl.clear();
    setState(() {});
  }

 @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_color1Animation.value!, _color2Animation.value!], // Use as novas animações
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent, // importante
            appBar: AppBar(
              title: const Text('Subjects'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                        controller: _ctrl,
                        decoration: const InputDecoration(hintText: 'New subject'),
                      )),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _cycleColor,
                        child: CircleAvatar(backgroundColor: selectedColor),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(onPressed: _addSubject, child: const Text('Add'))
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _buildList()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildList() {
    if (store.subjects.isEmpty) {
      return const Center(child: Text('No subjects yet.', style: TextStyle(color: Colors.white60)));
    }
    return ListView.builder(
      itemCount: store.subjects.length,
      itemBuilder: (context, i) {
        final s = store.subjects[i];
        return Card(
          color: Colors.white10,
          child: ListTile(
            leading: CircleAvatar(backgroundColor: Color(s.colorValue)),
            title: Text(s.name),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await store.removeSubject(s.id);
                setState(() {});
              },
            ),
          ),
        );
      },
    );
  }
}
