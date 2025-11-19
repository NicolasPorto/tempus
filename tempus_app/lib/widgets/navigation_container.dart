import 'package:flutter/material.dart';
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

  static const double _buttonWidth = 110.66;
  static const double _containerWidth = 346.0;
  static const double _containerHeight = 36.0;
  static const double _indicatorHeight = 29.0;

  static const double _stepSize = _containerWidth / 3.0;
  static const double _initialOffset = (_stepSize - _buttonWidth) / 2.0;

  final pages = const [TimerScreen(), TasksScreen(), StatsScreen()];

  final items = const [
    {'label': 'Timer', 'icon': Icons.timer, 'index': 0},
    {'label': 'Tarefas', 'icon': Icons.check_box, 'index': 1},
    {'label': 'Estatísticas', 'icon': Icons.bar_chart, 'index': 2},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            width: _containerWidth,
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

                  left: _initialOffset + (_current * _stepSize),
                  top: (_containerHeight - _indicatorHeight) / 3.0,

                  child: Container(
                    width: _buttonWidth,
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: items.map((item) {
                    final index = item['index'] as int;
                    final label = item['label'] as String;
                    final selected = index == _current;

                    return GestureDetector(
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
                      child: SizedBox(
                        width: _buttonWidth,
                        height: _indicatorHeight,
                        child: Center(
                          child: Transform.translate(
                            offset: const Offset(0, 2),
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
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : const Color(0xFFA0A0A0),
                                  fontSize: 14,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
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
