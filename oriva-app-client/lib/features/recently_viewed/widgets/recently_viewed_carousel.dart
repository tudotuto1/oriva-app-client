import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../recently_viewed_products_provider.dart';

class RecentlyViewedCarousel extends ConsumerWidget {
  const RecentlyViewedCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(recentlyViewedProductsProvider);

    return productsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (products) {
        if (products.isEmpty) return const SizedBox.shrink();

        final formatter = NumberFormat('#,###', 'fr_FR');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Row(
                children: [
                  const Icon(Icons.history,
                      color: OrivaColors.gold, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Vu récemment',
                    style: OrivaTypography.label(),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final p = products[i];
                  final images = (p['images'] as List?)?.cast<String>() ?? [];
                  final image = images.isNotEmpty ? images.first : null;
                  final price = (p['price'] as num?)?.toInt() ?? 0;

                  return GestureDetector(
                    onTap: () => context.push('/product/${p['id']}'),
                    child: Container(
                      width: 140,
                      decoration: BoxDecoration(
                        color: OrivaColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: OrivaColors.gold.withValues(alpha: 0.15),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: image != null
                                  ? CachedNetworkImage(
                                      imageUrl: image,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                        color: OrivaColors.surface,
                                      ),
                                      errorWidget: (_, __, ___) => Container(
                                        color: OrivaColors.surface,
                                        child: const Icon(
                                            Icons.image_not_supported_outlined,
                                            color: OrivaColors.muted),
                                      ),
                                    )
                                  : Container(color: OrivaColors.surface),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p['title']?.toString() ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: OrivaTypography.body(
                                      size: 12,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${formatter.format(price).replaceAll(',', ' ')} F',
                                    style: OrivaTypography.body(
                                      size: 13,
                                      color: OrivaColors.gold,
                                      weight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
