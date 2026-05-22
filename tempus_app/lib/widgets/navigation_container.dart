import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/timer_screen.dart';
import '../screens/tasks_screen.dart';
import '../screens/stats_screen.dart';
import '../controller/timer_controller.dart';
import '../theme/app_theme.dart';

class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class NavigationContainer extends StatefulWidget {
  const NavigationContainer({super.key});

  @override
  State<NavigationContainer> createState() => _NavigationContainerState();
}

class _NavigationContainerState extends State<NavigationContainer> {
  int _current = 0;
  final PageController _pageController = PageController(initialPage: 0);

  final pages = const [
    _KeepAlivePage(child: TimerScreen()),
    TasksScreen(),
    StatsScreen(),
  ];

  final items = const [
    {'label': 'Timer', 'asset': 'lib/assets/icons/icon_bar_timer.svg', 'index': 0},
    {'label': 'Tarefas', 'asset': 'lib/assets/icons/icon_bar_tasks.svg', 'index': 1},
    {'label': 'Stats', 'asset': 'lib/assets/icons/icon_bar_stats.svg', 'index': 2},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double pillWidth = min(screenWidth - 48.0, 300.0);

    return Column(
      children: [
        Expanded(
          child: PageView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _pageController,
            onPageChanged: (index) => setState(() => _current = index),
            children: pages,
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: isFocusModeGlobalNotifier,
          builder: (context, isFocusMode, child) {
            if (isFocusMode) return const SizedBox.shrink();
            return child!;
          },
          child: Padding(
            padding: EdgeInsets.only(
              bottom: bottomInset + 12,
              top: 8,
            ),
            child: Center(
              child: Container(
                width: pillWidth,
                height: 54,
                decoration: BoxDecoration(
                  color: TempusColors.surface,
                  borderRadius: BorderRadius.circular(27),
                  border: Border.all(color: TempusColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x50000000),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: items.map((item) {
                    final index = item['index'] as int;
                    final label = item['label'] as String;
                    final asset = item['asset'] as String;
                    final selected = index == _current;

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                          setState(() => _current = index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: selected
                                ? TempusColors.accent.withOpacity(0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          margin: const EdgeInsets.all(5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                asset,
                                width: 16,
                                height: 16,
                                colorFilter: ColorFilter.mode(
                                  selected
                                      ? TempusColors.accent
                                      : TempusColors.textSub,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                label,
                                style: TextStyle(
                                  color: selected
                                      ? TempusColors.text
                                      : TempusColors.textSub,
                                  fontSize: 11,
                                  fontFamily: 'Arimo',
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
