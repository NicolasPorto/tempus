import 'package:flutter/material.dart';
import '../screens/timer_screen.dart';
import '../screens/tasks_screen.dart';
import '../screens/stats_screen.dart';

class NavigationContainer extends StatefulWidget {
  const NavigationContainer({super.key});

  @override
  State<NavigationContainer> createState() => _NavigationContainerState();
}

class _NavigationContainerState extends State<NavigationContainer> {
  int _current = 0;

  final pages = const [
    TimerScreen(),
    //TasksScreen(),            // Índice 1: Tarefas
    //StatsScreen(),            // Índice 2: Estatísticas
  ];

  final items = const [
    {'label': 'Timer', 'icon': Icons.timer, 'index': 0},
    {'label': 'Tarefas', 'icon': Icons.check_box, 'index': 1},
    {'label': 'Estatísticas', 'icon': Icons.bar_chart, 'index': 2},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 346,
          height: 36,
          margin: const EdgeInsets.only(top: 32, left: 22, right: 22),
          decoration: ShapeDecoration(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0x19FFFEFE)),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              final index = item['index'] as int;
              final label = item['label'] as String;
              final selected = index == _current;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _current = index;
                  });
                },
                child: Container(
                  width: 110.66,
                  height: 29,
                  decoration: selected
                      ? ShapeDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment(0.00, 0.00),
                            end: Alignment(1.00, 1.00),
                            colors: [Color(0x33AC46FF), Color(0x332B7FFF)],
                          ),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1,
                              color: Color(0x33FFFEFE),
                            ),
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
                        )
                      : null,
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
                      child: Text(
                        label,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : const Color(0xFFA0A0A0),
                          fontSize: 14,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            child: IndexedStack(index: _current, children: pages),
          ),
        ),
      ],
    );
  }
}
