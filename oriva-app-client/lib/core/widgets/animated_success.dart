import 'package:flutter/material.dart';

class AnimatedSuccessCheck extends StatefulWidget {
  const AnimatedSuccessCheck({
    super.key,
    this.size = 96,
    this.color = const Color(0xFFC9A96E),
  });

  final double size;
  final Color color;

  @override
  State<AnimatedSuccessCheck> createState() => _AnimatedSuccessCheckState();
}

class _AnimatedSuccessCheckState extends State<AnimatedSuccessCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  late final Animation<double> _circleScale = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).chain(CurveTween(curve: Curves.easeOutBack)).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.0, 0.5),
        ),
      );

  late final Animation<double> _checkOpacity = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ),
  );

  late final Animation<double> _checkScale = Tween<double>(
    begin: 0.5,
    end: 1.0,
  ).chain(CurveTween(curve: Curves.elasticOut)).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.4, 1.0),
        ),
      );

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
  }

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
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: _circleScale.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: 0.15),
                  border: Border.all(color: widget.color, width: 2),
                ),
              ),
            ),
            Opacity(
              opacity: _checkOpacity.value,
              child: Transform.scale(
                scale: _checkScale.value,
                child: Icon(
                  Icons.check_rounded,
                  color: widget.color,
                  size: widget.size * 0.55,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
