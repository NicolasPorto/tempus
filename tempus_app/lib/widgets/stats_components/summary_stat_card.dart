import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SummaryStatCard extends StatelessWidget {
  final String title;
  final String value;
  final List<Color> iconColors;
  final List<Color> barColors;
  final IconData icon;

  const SummaryStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.iconColors,
    required this.barColors,
    this.icon = Icons.star,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = barColors.first;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: TempusColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TempusColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: barColors),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: iconColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Center(
                      child: Icon(icon, color: accentColor, size: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        )),
                        child: child,
                      ),
                    ),
                    child: Text(
                      key: ValueKey(value),
                      value,
                      style: TextStyle(
                        color: value == '...'
                            ? TempusColors.textSub
                            : TempusColors.text,
                        fontSize: 34,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: TempusColors.textSub,
                      fontSize: 12,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
