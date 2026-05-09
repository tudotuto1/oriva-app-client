import 'dart:math';
import 'package:flutter/material.dart';

class OrivaConfetti extends StatefulWidget {
  const OrivaConfetti({
    super.key,
    this.particleCount = 30,
    this.duration = const Duration(milliseconds: 1800),
  });

  final int particleCount;
  final Duration duration;

  @override
  State<OrivaConfetti> createState() => _OrivaConfettiState();
}

class _OrivaConfettiState extends State<OrivaConfetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final List<_Particle> _particles;

  static const _colors = [
    Color(0xFFC9A96E),
    Color(0xFFF5F0E8),
    Color(0xFFE6CFA4),
    Color(0xFFA88857),
  ];

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _particles = List.generate(widget.particleCount, (i) {
      return _Particle(
        startX: rng.nextDouble(),
        velocityX: (rng.nextDouble() - 0.5) * 0.6,
        velocityY: 0.6 + rng.nextDouble() * 0.6,
        rotationSpeed: (rng.nextDouble() - 0.5) * 8,
        size: 6 + rng.nextDouble() * 8,
        color: _colors[rng.nextInt(_colors.length)],
        delay: rng.nextDouble() * 0.3,
      );
    });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          return CustomPaint(
            size: Size.infinite,
            painter: _ConfettiPainter(
              particles: _particles,
              progress: _ctrl.value,
            ),
          );
        },
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.startX,
    required this.velocityX,
    required this.velocityY,
    required this.rotationSpeed,
    required this.size,
    required this.color,
    required this.delay,
  });

  final double startX;
  final double velocityX;
  final double velocityY;
  final double rotationSpeed;
  final double size;
  final Color color;
  final double delay;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.progress});

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress - p.delay).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final x = p.startX * size.width + p.velocityX * size.width * t;
      final y = -20 + p.velocityY * size.height * t * 1.4;
      final opacity = (1 - t).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotationSpeed * t);

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.4,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.progress != progress;
}
