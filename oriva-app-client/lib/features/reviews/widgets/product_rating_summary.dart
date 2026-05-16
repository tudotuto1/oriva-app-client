import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../review_providers.dart';
import 'star_rating.dart';

class ProductRatingSummary extends ConsumerWidget {
  final String productId;
  const ProductRatingSummary({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(reviewStatsProvider(productId));

    return statsAsync.when(
      loading: () => const SizedBox(height: 60),
      error: (_, __) => const SizedBox.shrink(),
      data: (stats) {
        final hasReviews = stats.reviewCount > 0;
        return InkWell(
          onTap: () => context.push('/reviews/$productId'),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: OrivaColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: OrivaColors.gold.withValues(alpha: 0.12),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                if (hasReviews) ...[
                  Text(
                    stats.averageRating.toStringAsFixed(1),
                    style: OrivaTypography.display(
                      size: 28,
                      color: OrivaColors.gold,
                      weight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StarRating(rating: stats.averageRating, size: 16),
                      const SizedBox(height: 4),
                      Text(
                        '${stats.reviewCount} avis',
                        style: OrivaTypography.body(
                            size: 13, color: OrivaColors.muted),
                      ),
                    ],
                  ),
                ] else ...[
                  Icon(LucideIcons.star,
                      size: 22, color: OrivaColors.muted.withValues(alpha: 0.4)),
                  const SizedBox(width: 12),
                  Text(
                    'Aucun avis pour le moment',
                    style: OrivaTypography.body(
                        size: 14, color: OrivaColors.muted),
                  ),
                ],
                const Spacer(),
                Icon(LucideIcons.chevronRight,
                    size: 20, color: OrivaColors.muted),
              ],
            ),
          ),
        );
      },
    );
  }
}
