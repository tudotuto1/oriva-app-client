import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class NotificationCountBadge extends StatelessWidget {
  final int count;
  final double size;

  const NotificationCountBadge({
    super.key,
    required this.count,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final label = count > 99 ? '99+' : count.toString();
    return Container(
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: OrivaColors.gold,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: OrivaTypography.body(
          size: 11,
          color: OrivaColors.black,
          weight: FontWeight.w700,
        ),
      ),
    );
  }
}
