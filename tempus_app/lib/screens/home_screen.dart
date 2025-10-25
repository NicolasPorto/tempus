import 'package:flutter/material.dart';
import 'pomodoro_screen.dart';
import 'tasks_screen.dart';
import 'subjects_screen.dart';
import 'stats_screen.dart';
import '../widgets/animated_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _current = 0;
  final pages = const [
    PomodoroScreen(),
    TasksScreen(),
    SubjectsScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return OrbDynamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: pages[_current],
        bottomNavigationBar: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (index) {
              final icons = [
                Icons.timer,
                Icons.check_box,
                Icons.book,
                Icons.show_chart,
              ];
              final labels = ['Tempus', 'Tasks', 'Subjects', 'Stats'];
              final selected = index == _current;

              return GestureDetector(
                onTap: () => setState(() => _current = index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: selected
                          ? BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFA661FA), Color(0xFF7C4DFF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurpleAccent.withOpacity(
                                    0.4,
                                  ),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            )
                          : null,
                      child: Icon(
                        icons[index],
                        color: selected ? Colors.white : Colors.white60,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[index],
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white60,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
