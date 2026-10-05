import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../libraries/globals.dart';
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

  const _NavItemData({required this.label, this.asset, this.iconData});
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
    _NavItemData(label: 'Foco', asset: 'lib/assets/icons/icon_bar_timer.svg'),
    _NavItemData(label: 'Tarefas', asset: 'lib/assets/icons/icon_bar_tasks.svg'),
    _NavItemData(label: 'Stats', asset: 'lib/assets/icons/icon_bar_stats.svg'),
    _NavItemData(label: 'Perfil', iconData: Icons.person_rounded),
  ];

  @override
  void initState() {
    super.initState();
    tempusGlobals.tabRequest.addListener(_onTabRequest);
  }

  void _onTabRequest() {
    final index = tempusGlobals.tabRequest.value;
    if (index != null && mounted) _goTo(index, haptic: false);
  }

  @override
  void dispose() {
    tempusGlobals.tabRequest.removeListener(_onTabRequest);
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index, {bool haptic = true}) {
    if (haptic) HapticFeedback.selectionClick();
    final distance = (index - _current).abs();
    if (distance > 1) {
      // Salto direto evita "passar" visualmente pelas abas intermediárias.
      _pageController.jumpToPage(index);
    } else {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    }
    setState(() => _current = index);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

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
        // Scrim sob a barra de status: o conteúdo rolado não briga com
        // os ícones do sistema.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).padding.top + 18,
          child: const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xF205040A), Color(0xB305040A), Color(0x0005040A)],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: bottomInset + 16,
          left: 20,
          right: 20,
          child: ValueListenableBuilder<bool>(
            valueListenable: isFocusModeGlobalNotifier,
            builder: (context, isFocusMode, child) => IgnorePointer(
              ignoring: isFocusMode,
              child: AnimatedSlide(
                offset: isFocusMode ? const Offset(0, 2.0) : Offset.zero,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                child: AnimatedOpacity(
                  opacity: isFocusMode ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 260),
                  child: child,
                ),
              ),
            ),
            child: Center(
              child: _Pill(current: _current, items: items, onTap: _goTo),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Pill ──────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final int current;
  final List<_NavItemData> items;
  final ValueChanged<int> onTap;

  const _Pill({
    required this.current,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 380),
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 30,
            spreadRadius: -4,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF13101C).withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    flex: i == current ? 16 : 10,
                    child: _NavItem(
                      data: items[i],
                      selected: i == current,
                      onTap: () => onTap(i),
                    ),
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

class _NavItem extends StatelessWidget {
  final _NavItemData data;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? Colors.white : Colors.white.withValues(alpha: 0.42);
    final icon = data.asset != null
        ? SvgPicture.asset(
            data.asset!,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          )
        : Icon(data.iconData, size: 21, color: color);

    return Semantics(
      button: true,
      selected: selected,
      label: data.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: selected
                  ? LinearGradient(
                      colors: [
                        TempusColors.accent.withValues(alpha: 0.95),
                        const Color(0xFF7C6CF8).withValues(alpha: 0.95),
                      ],
                    )
                  : null,
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: TempusColors.accent.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                Flexible(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    child: selected
                        ? Padding(
                            padding: const EdgeInsets.only(left: 7),
                            child: Text(
                              data.label,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              softWrap: false,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
