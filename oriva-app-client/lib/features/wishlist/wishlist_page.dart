import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'wishlist_providers.dart';
import 'widgets/wishlist_heart_button.dart';

class WishlistPage extends ConsumerWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(wishlistItemsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080808),
        title: const Text(
          'Mes favoris',
          style: TextStyle(color: Color(0xFFF5F0E8)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFC9A96E)),
      ),
      body: asyncItems.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFC9A96E)),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Erreur : $e',
              style: const TextStyle(color: Color(0xFFF5F0E8)),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return RefreshIndicator(
              color: const Color(0xFFC9A96E),
              backgroundColor: const Color(0xFF111111),
              onRefresh: () async {
                ref.invalidate(wishlistItemsProvider);
                await ref.read(wishlistItemsProvider.future);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Aucun favori pour le moment.\n\n'
                        'Appuie sur le cœur sur un produit pour l\'ajouter ici.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: const Color(0xFFC9A96E),
            backgroundColor: const Color(0xFF111111),
            onRefresh: () async {
              ref.invalidate(wishlistItemsProvider);
              await ref.read(wishlistItemsProvider.future);
            },
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.62,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                final product = item['products'] as Map<String, dynamic>;
                return _WishlistCard(product: product);
              },
            ),
          );
        },
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  const _WishlistCard({required this.product});
  final Map<String, dynamic> product;

  @override
  Widget build(BuildContext context) {
    final id = product['id'].toString();
    final title = product['title']?.toString() ?? '';
    final images = (product['images'] as List?)?.cast<String>() ?? [];
    final firstImage = images.isNotEmpty ? images.first : null;
    final priceFcfa =
        (product['vendor_price_fcfa_at_creation'] as num?)?.toInt() ?? 0;
    final isArchived = product['is_archived'] == true;

    return GestureDetector(
      onTap: isArchived
          ? null
          : () => context.push('/product/$id'),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: firstImage != null
                          ? CachedNetworkImage(
                              imageUrl: firstImage,
                              fit: BoxFit.cover,
                            )
                          : Container(color: const Color(0xFF1A1A1A)),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: WishlistHeartButton(productId: id, size: 22),
                  ),
                  if (isArchived)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.6),
                        alignment: Alignment.center,
                        child: const Text(
                          'Indisponible',
                          style: TextStyle(
                            color: Color(0xFFF5F0E8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF5F0E8),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatFcfa(priceFcfa)} FCFA',
                    style: const TextStyle(
                      color: Color(0xFFC9A96E),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFcfa(int amount) {
    final str = amount.toString();
    final buf = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(' ');
      buf.write(str[i]);
    }
    return buf.toString();
  }
}
