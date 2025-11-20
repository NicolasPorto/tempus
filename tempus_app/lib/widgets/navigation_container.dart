import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../screens/timer_screen.dart';
import '../screens/tasks_screen.dart';
import '../screens/stats_screen.dart';
import '../controller/timer_controller.dart';

class NavigationContainer extends StatefulWidget {
  const NavigationContainer({super.key});

  @override
  State<NavigationContainer> createState() => _NavigationContainerState();
}

class _NavigationContainerState extends State<NavigationContainer> {
  int _current = 0;
  final PageController _pageController = PageController(initialPage: 0);

  static const double _containerHeight = 36.0;
  static const double _indicatorHeight = 29.0;

  static const double _originalWidth = 346.0;
  static const double _originalButtonWidth = 110.66;

  final pages = const [TimerScreen(), TasksScreen(), StatsScreen()];

  final items = const [
    {
      'label': 'Timer',
      'asset': 'lib/assets/icons/icon_bar_timer.svg',
      'index': 0,
    },
    {
      'label': 'Tarefas',
      'asset': 'lib/assets/icons/icon_bar_tasks.svg',
      'index': 1,
    },
    {
      'label': 'Estatísticas',
      'asset': 'lib/assets/icons/icon_bar_stats.svg',
      'index': 2,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenAvailable = MediaQuery.of(context).size.width - 44.0;

    final double containerWidth = min(screenAvailable, _originalWidth);

    final double stepSize = containerWidth / 3.0;

    final double scaleRatio = containerWidth / _originalWidth;
    final double indicatorButtonWidth = _originalButtonWidth * scaleRatio;

    final double initialOffset = (stepSize - indicatorButtonWidth) / 2.0;

    return Column(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: isFocusModeGlobalNotifier,
          builder: (context, isFocusMode, child) {
            if (isFocusMode) {
              return const SizedBox.shrink();
            }
            return child!;
          },
          child: Container(
            width: containerWidth,
            height: _containerHeight,
            margin: const EdgeInsets.only(top: 32, left: 22, right: 22),
            decoration: ShapeDecoration(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Color(0x19FFFEFE)),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: initialOffset + (_current * stepSize),
                  top: (_containerHeight - _indicatorHeight) / 3.0,
                  child: Container(
                    width: indicatorButtonWidth,
                    height: _indicatorHeight,
                    decoration: ShapeDecoration(
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
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: items.map((item) {
                    final index = item['index'] as int;
                    final label = item['label'] as String;
                    final asset = item['asset'] as String;
                    final selected = index == _current;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                          setState(() {
                            _current = index;
                          });
                        },
                        child: Center(
                          child: ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                colors: [
                                  Color(0xFFAC46FF),
                                  Color(0xFF2B7FFF),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: SvgPicture.asset(
                                    asset,
                                    width: 14,
                                    height: 14,
                                    colorFilter: ColorFilter.mode(
                                      selected
                                          ? Colors.white
                                          : const Color(0xFFA0A0A0),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: AutoSizeText(
                                      label,
                                      maxLines: 1,
                                      minFontSize: 8,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: selected
                                            ? Colors.white
                                            : const Color(0xFFA0A0A0),
                                        fontSize: 13,
                                        fontFamily: 'Arimo',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: PageView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _current = index;
              });
            },
            children: pages,
          ),
        ),
      ],
    );
  }
}