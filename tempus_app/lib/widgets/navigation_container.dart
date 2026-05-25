import 'dart:ui' show ImageFilter;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/timer_screen.dart';
import '../screens/tasks_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/profile_screen.dart';
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

class _NavItemData {
  final String label;
  final String? asset;
  final IconData? iconData;
  final int index;

  const _NavItemData({
    required this.label,
    this.asset,
    this.iconData,
    required this.index,
  });
}

class NavigationContainer extends StatefulWidget {
  const NavigationContainer({super.key});

  @override
  State<NavigationContainer> createState() => _NavigationContainerState();
}

class _NavigationContainerState extends State<NavigationContainer> {
  int _current = 0;
  final PageController _pageController = PageController();

  static const pages = [
    _KeepAlivePage(child: TimerScreen()),
    _KeepAlivePage(child: TasksScreen()),
    _KeepAlivePage(child: StatsScreen()),
    _KeepAlivePage(child: ProfileScreen()),
  ];

  static const items = [
    _NavItemData(label: 'Timer',   asset: 'lib/assets/icons/icon_bar_timer.svg', index: 0),
    _NavItemData(label: 'Tarefas', asset: 'lib/assets/icons/icon_bar_tasks.svg', index: 1),
    _NavItemData(label: 'Stats',   asset: 'lib/assets/icons/icon_bar_stats.svg', index: 2),
    _NavItemData(label: 'Perfil',  iconData: Icons.person_rounded,               index: 3),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    HapticFeedback.selectionClick();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
    setState(() => _current = index);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final double sw = MediaQuery.of(context).size.width;
    final double pillWidth = min(sw - 40.0, 340.0);

    return Stack(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: isFocusModeGlobalNotifier,
          builder: (context, isFocusMode, child) => PageView(
            physics: isFocusMode
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            controller: _pageController,
            onPageChanged: (i) => setState(() => _current = i),
            children: pages,
          ),
        ),
        Positioned(
          bottom: bottomInset + 18,
          left: 0,
          right: 0,
          child: ValueListenableBuilder<bool>(
            valueListenable: isFocusModeGlobalNotifier,
            builder: (context, isFocusMode, child) => AnimatedSlide(
              offset: isFocusMode ? const Offset(0, 2.0) : Offset.zero,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              child: AnimatedOpacity(
                opacity: isFocusMode ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 260),
                child: child,
              ),
            ),
            child: Center(
              child: _Pill(
                width: pillWidth,
                current: _current,
                items: items,
                onTap: _onTap,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Pill ──────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final double width;
  final int current;
  final List<_NavItemData> items;
  final ValueChanged<int> onTap;

  const _Pill({
    required this.width,
    required this.current,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(31),
        boxShadow: [
          // Profundidade
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.50),
            blurRadius: 32,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
          // Halo roxo suave
          BoxShadow(
            color: TempusColors.accent.withValues(alpha: 0.15),
            blurRadius: 24,
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(31),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
          child: Container(
            decoration: BoxDecoration(
              // Dark glass: opaco o suficiente para ser legível,
              // transparente o suficiente para o blur respirar
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF16101F).withValues(alpha: 0.82),
                  const Color(0xFF0C0912).withValues(alpha: 0.88),
                ],
              ),
              borderRadius: BorderRadius.circular(31),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
                width: 1.0,
              ),
            ),
            child: Stack(
              children: [
                // Specular: borda superior luminosa — define o vidro
                Positioned(
                  top: 0, left: 20, right: 20,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.38),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Items
                Row(
                  children: items
                      .map((item) => Expanded(
                            child: _NavItem(
                              data: item,
                              selected: item.index == current,
                              onTap: () => onTap(item.index),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Nav item ──────────────────────────────────────────────────────

class _NavItem extends StatefulWidget {
  final _NavItemData data;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.82)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  Color get _iconColor => widget.selected
      ? TempusColors.accent
      : Colors.white.withValues(alpha: 0.38);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) { _press.reverse(); widget.onTap(); },
      onTapCancel: () => _press.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          height: 62,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              width: 46,
              height: 40,
              decoration: widget.selected
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          TempusColors.accent.withValues(alpha: 0.28),
                          TempusColors.accent.withValues(alpha: 0.12),
                        ],
                      ),
                      border: Border.all(
                        color: TempusColors.accent.withValues(alpha: 0.45),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: TempusColors.accent.withValues(alpha: 0.28),
                          blurRadius: 16,
                          spreadRadius: -2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    )
                  : const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(13)),
                    ),
              child: Center(
                child: AnimatedScale(
                  scale: widget.selected ? 1.10 : 1.0,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutBack,
                  child: widget.data.asset != null
                      ? SvgPicture.asset(
                          widget.data.asset!,
                          width: 21,
                          height: 21,
                          colorFilter:
                              ColorFilter.mode(_iconColor, BlendMode.srcIn),
                        )
                      : Icon(widget.data.iconData, size: 21, color: _iconColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
