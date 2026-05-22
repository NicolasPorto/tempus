import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempus_app/controller/timer_controller.dart';
import 'package:tempus_app/services/supabase_service.dart';

import '../widgets/timer_controls.dart';
import '../widgets/subject_manager_modal.dart';
import '../widgets/timer_components/timer_header.dart';
import '../widgets/timer_components/subject_selector.dart';
import '../widgets/timer_components/empty_subject_card.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TimerController(
        supabaseService: Provider.of<SupabaseService>(context, listen: false),
      ),
      child: const _TimerScreenContent(),
    );
  }
}

class _TimerScreenContent extends StatelessWidget {
  const _TimerScreenContent();

  void _showSubjectManagerModal(BuildContext context) async {
    final controller = Provider.of<TimerController>(context, listen: false);

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const SubjectManagerModal(),
    );

    controller.loadSubjects();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TimerController>(context);

    return GestureDetector(
      onTap: controller.handleUserInteraction,
      onPanDown: (_) => controller.handleUserInteraction(),
      child: SingleChildScrollView(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: animation.drive(
                  Tween<double>(begin: 0.88, end: 1.0)
                      .chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              ),
            );
          },
          child: controller.isFocusMode
              ? _buildFocusView(context, controller)
              : _buildMainView(context, controller),
        ),
      ),
    );
  }

  Widget _buildMainView(BuildContext context, TimerController controller) {
    return Center(
      key: const ValueKey('main_view'),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TimerHeader(),
              const SizedBox(height: 24),
              SubjectSelector(
                subjects: controller.subjects,
                selectedSubject: controller.selectedSubject,
                isLoading: controller.isLoading,
                onManageTap: () => _showSubjectManagerModal(context),
                onSubjectChanged: controller.selectSubject,
              ),
              const SizedBox(height: 32),
              TimerControls(
                key: const ValueKey('timer_controls'),
                selectedSubject: controller.selectedSubject,
                onToggleTimer: controller.toggleTimer,
                onResetTimer: controller.resetTimer,
                onDurationChanged: (m) => controller.setDuration(m),
                currentDuration: controller.currentDuration,
                initialDuration: controller.initialDuration,
                isRunning: controller.isRunning,
                isPomodoroMode: controller.isPomodoroMode,
                pomodoroPhase: controller.pomodoroPhase,
                pomodoroRound: controller.pomodoroRound,
                onTogglePomodoroMode: controller.togglePomodoroMode,
              ),
              if (controller.subjects.isEmpty && !controller.isLoading) ...[
                const SizedBox(height: 24),
                EmptySubjectCard(
                  onCreateTap: () => _showSubjectManagerModal(context),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFocusView(BuildContext context, TimerController controller) {
    return Center(
      key: const ValueKey('focus'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
        child: TimerControls(
          key: const ValueKey('timer_controls'),
          selectedSubject: controller.selectedSubject,
          onToggleTimer: controller.toggleTimer,
          onResetTimer: controller.resetTimer,
          onDurationChanged: (m) => controller.setDuration(m),
          currentDuration: controller.currentDuration,
          initialDuration: controller.initialDuration,
          isRunning: controller.isRunning,
          isPomodoroMode: controller.isPomodoroMode,
          pomodoroPhase: controller.pomodoroPhase,
          pomodoroRound: controller.pomodoroRound,
          onTogglePomodoroMode: controller.togglePomodoroMode,
        ),
      ),
    );
  }
}
