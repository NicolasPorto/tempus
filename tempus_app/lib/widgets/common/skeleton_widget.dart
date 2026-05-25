import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: TempusColors.surfaceHigh,
            borderRadius: widget.borderRadius,
          ),
        ),
      ),
    );
  }
}

/// Pre-composed skeleton for a stat card (icon + value + label)
class SkeletonStatCard extends StatelessWidget {
  const SkeletonStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TempusColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TempusColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonBox(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SkeletonBox(
                  height: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SkeletonBox(width: 80, height: 32, borderRadius: BorderRadius.circular(8)),
          const SizedBox(height: 6),
          SkeletonBox(width: 100, height: 10, borderRadius: BorderRadius.circular(5)),
        ],
      ),
    );
  }
}

/// Pre-composed skeleton for a task tile
class SkeletonTaskTile extends StatelessWidget {
  const SkeletonTaskTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: 72,
      decoration: BoxDecoration(
        color: TempusColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TempusColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: TempusColors.surfaceHigh,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const SkeletonBox(
            width: 24,
            height: 24,
            borderRadius: BorderRadius.all(Radius.circular(7)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: double.infinity,
                  height: 13,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 6),
                SkeletonBox(
                  width: 80,
                  height: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}
