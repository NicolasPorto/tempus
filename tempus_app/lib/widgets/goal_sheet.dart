import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controller/timer_controller.dart';
import '../theme/app_theme.dart';
import 'common/ui.dart';

/// Bottom sheet para definir a meta diária de estudo.
Future<void> showDailyGoalSheet(
    BuildContext context, TimerController controller) {
  HapticFeedback.selectionClick();
  int selected =
      controller.dailyGoalMinutes > 0 ? controller.dailyGoalMinutes : 120;
  const quick = [30, 60, 120, 180, 240];

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => SheetScaffold(
        title: 'Meta diária',
        subtitle: 'Quanto tempo de foco você quer por dia?',
        child: Column(
          children: [
            Center(
              child: GradientText(
                formatMinutes(selected),
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: selected.toDouble(),
              min: 15,
              max: 480,
              divisions: 31,
              onChanged: (v) {
                if (v.round() != selected) HapticFeedback.selectionClick();
                setSheet(() => selected = v.round());
              },
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final q in quick)
                  GestureDetector(
                    onTap: () => setSheet(() => selected = q),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected == q
                            ? TempusColors.accent.withValues(alpha: 0.18)
                            : TempusColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected == q
                              ? TempusColors.accent.withValues(alpha: 0.6)
                              : TempusColors.border,
                        ),
                      ),
                      child: Text(
                        formatMinutes(q),
                        style: TextStyle(
                          color: selected == q
                              ? TempusColors.text
                              : TempusColors.textSub,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Salvar meta',
              icon: Icons.flag_rounded,
              onTap: () {
                controller.setDailyGoal(selected);
                Navigator.pop(ctx);
              },
            ),
            if (controller.dailyGoalMinutes > 0) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  controller.setDailyGoal(0);
                  Navigator.pop(ctx);
                },
                child: const Text(
                  'Remover meta',
                  style: TextStyle(
                    color: TempusColors.textSub,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
