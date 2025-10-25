import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/pomodoro_timer.dart';
import '../models/subject.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({Key? key}) : super(key: key);

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen>
    with TickerProviderStateMixin {
  static var defaultMinutes = 25;
  String selectedSubjectId = '';
  final store = StorageService.instance;

  @override
  void initState() {
    super.initState();
    if (store.subjects.isNotEmpty) selectedSubjectId = store.subjects.first.id;
  }

  void _onSessionComplete(String subjectId) async {
    await store.addSessionFromSubject(
      subjectId,
      _PomodoroScreenState.defaultMinutes,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tempus',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Center(
                child: PomodoroTimer(
                  key: ValueKey(
                    defaultMinutes,
                  ), // força reconstrução quando muda
                  minutes: defaultMinutes, // passa o tempo atual
                  onComplete: () async {
                    await StorageService.instance.addSessionFromSubject(
                      selectedSubjectId,
                      defaultMinutes,
                    );
                    setState(() {});
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [15, 25, 45].map((minutes) {
                final isSelected = minutes == defaultMinutes;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      defaultMinutes = minutes; // Atualiza tempo
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFFA661FA), Color(0xFF7C4DFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : Colors.white10,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.white30,
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color.fromARGB(
                                  255,
                                  105,
                                  52,
                                  252,
                                ).withOpacity(0.4),
                                blurRadius: 5,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      '$minutes min',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 8),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
