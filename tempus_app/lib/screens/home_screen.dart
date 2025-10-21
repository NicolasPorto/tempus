import 'package:flutter/material.dart';
import 'pomodoro_screen.dart';
import 'tasks_screen.dart';
import 'subjects_screen.dart';
import 'stats_screen.dart';

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
    return Scaffold(
      body: pages[_current],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _current,
        backgroundColor: Colors.transparent,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.white60,
        onTap: (i) => setState(() => _current = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Focus'),
          BottomNavigationBarItem(icon: Icon(Icons.check_box), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Subjects'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Stats'),
        ],
      ),
    );
  }
}
