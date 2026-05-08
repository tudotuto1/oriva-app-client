import 'package:flutter/material.dart';

class OrivaShimmer extends StatefulWidget {
  const OrivaShimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFF1A1A1A),
    this.highlightColor = const Color(0xFF2A2A2A),
  });

  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  @override
  State<OrivaShimmer> createState() => _OrivaShimmerState();
}

class _OrivaShimmerState extends State<OrivaShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                (_ctrl.value - 0.3).clamp(0.0, 1.0),
                _ctrl.value.clamp(0.0, 1.0),
                (_ctrl.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
