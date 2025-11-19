import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempus_app/controller/timer_controller.dart';
import 'package:tempus_app/services/api_service.dart';

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
        apiService: Provider.of<ApiService>(context, listen: false),
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
        child: Stack(
          children: [
            SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation.drive(
                        Tween<double>(
                          begin: 0.8,
                          end: 1.0,
                        ).chain(CurveTween(curve: Curves.easeOutCubic)),
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
          ],
        ),
      ),
    );
  }

  Widget _buildMainView(BuildContext context, TimerController controller) {
    return Center(
      key: const ValueKey('main_view'),
      child: Container(
        color: Colors.transparent,
        constraints: const BoxConstraints(maxWidth: 378),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TimerHeader(),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SubjectSelector(
                    subjects: controller.subjects,
                    selectedSubject: controller.selectedSubject,
                    isLoading: controller.isLoading,
                    onManageTap: () => _showSubjectManagerModal(context),
                    onSubjectChanged: controller.selectSubject,
                  ),

                  const SizedBox(height: 40),

                  TimerControls(
                    key: const ValueKey('timer_controls'),
                    selectedSubject: controller.selectedSubject,
                    onToggleTimer: controller.toggleTimer,
                    onResetTimer: controller.resetTimer,
                    currentDuration: controller.currentDuration,
                    initialDuration: controller.initialDuration,
                    isRunning: controller.isRunning,
                  ),

                  const SizedBox(height: 40),

                  if (controller.subjects.isEmpty && !controller.isLoading)
                    EmptySubjectCard(
                      onCreateTap: () => _showSubjectManagerModal(context),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusView(BuildContext context, TimerController controller) {
    const double requiredTopSpacing = 200.0;
    return Center(
      key: const ValueKey('focus'),
      child: Column(
        children: [
          const SizedBox(height: requiredTopSpacing),
          TimerControls(
            key: const ValueKey('timer_controls'),
            selectedSubject: controller.selectedSubject,
            onToggleTimer: controller.toggleTimer,
            onResetTimer: controller.resetTimer,
            currentDuration: controller.currentDuration,
            initialDuration: controller.initialDuration,
            isRunning: controller.isRunning,
          ),
        ],
      ),
    );
  }
}
