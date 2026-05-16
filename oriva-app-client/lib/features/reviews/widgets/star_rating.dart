import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final int starCount;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 16,
    this.starCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (i) {
        final filled = rating >= i + 1;
        final half = !filled && rating > i && rating < i + 1;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            half
                ? LucideIcons.starHalf
                : filled
                    ? LucideIcons.star
                    : LucideIcons.star,
            color: filled || half
                ? OrivaColors.gold
                : OrivaColors.muted.withValues(alpha: 0.3),
            size: size,
            fill: filled ? 1.0 : 0.0,
          ),
        );
      }),
    );
  }
}

class InteractiveStarRating extends StatelessWidget {
  final int currentRating;
  final ValueChanged<int> onChanged;
  final double size;

  const InteractiveStarRating({
    super.key,
    required this.currentRating,
    required this.onChanged,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final value = i + 1;
        final filled = currentRating >= value;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onChanged(value);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              LucideIcons.star,
              color: filled
                  ? OrivaColors.gold
                  : OrivaColors.muted.withValues(alpha: 0.3),
              size: size,
              fill: filled ? 1.0 : 0.0,
            ),
          ),
        );
      }),
    );
  }
}
