import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/supabase/supabase_service.dart';
import '../../core/widgets/oriva_error_state.dart';
import '../cart/cart_provider.dart';
import '../home/home_shell.dart';
import '../recently_viewed/recently_viewed_provider.dart';
import '../wishlist/widgets/wishlist_heart_button.dart';
import '../reviews/widgets/product_rating_summary.dart';
import '../vendors/follow_button.dart';
import 'widgets/share_product_button.dart';
import 'widgets/image_zoom_page.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final String productId;
  final String? heroTag;
  const ProductDetailPage({
    super.key,
    required this.productId,
    this.heroTag,
  });

  @override
  ConsumerState<ProductDetailPage> createState() =>
      _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  Map<String, dynamic>? _product;
  Map<String, dynamic>? _vendor;
  bool _loading = true;
  final ValueNotifier<int> _currentImageIndex = ValueNotifier<int>(0);
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadProduct();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recentlyViewedProvider.notifier).add(widget.productId);
    });
  }

  @override
  void dispose() {
    _currentImageIndex.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    try {
      final product = await SupabaseService.client
          .from('products_with_pricing')
          .select()
          .eq('id', widget.productId)
          .single();

      Map<String, dynamic>? vendor;
      if (product['vendor_id'] != null) {
        try {
          vendor = await SupabaseService.client
              .from('profiles')
              .select('display_name, avatar_url')
              .eq('id', product['vendor_id'])
              .single();
        } catch (_) {}
      }

      setState(() {
        _product = product;
        _vendor = vendor;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  String _formatPrice(num price) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return '${formatter.format(price).replaceAll(',', ' ')} F CFA';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: OrivaColors.gold)),
      );
    }

    if (_product == null) {
      return Scaffold(
        backgroundColor: OrivaColors.black,
        appBar: AppBar(
          backgroundColor: OrivaColors.black,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft,
                color: OrivaColors.cream),
            onPressed: () => context.pop(),
          ),
        ),
        body: OrivaErrorState(
          icon: LucideIcons.packageX,
          message: 'Ce produit est indisponible.',
          hint: 'Il a peut-être été retiré ou archivé.',
          onRetry: _loadProduct,
        ),
      );
    }

    final images = List<String>.from(_product!['images'] ?? []);
    final stock = _product!['stock'] ?? 0;
    final outOfStock = stock == 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Galerie
          SliverAppBar(
            expandedHeight: 420,
            pinned: true,
            backgroundColor: OrivaColors.black,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor:
                    OrivaColors.black.withValues(alpha: 0.6),
                child: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft,
                      color: OrivaColors.cream),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: ShareProductButton(
                  product: _product!,
                  vendorName: _vendor?['display_name']?.toString(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: WishlistHeartButton(
                  productId: _product!['id'].toString(),
                  size: 26,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: images.isEmpty
                  ? Container(color: OrivaColors.surface)
                  : Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (i) =>
                              _currentImageIndex.value = i,
                          itemCount: images.length,
                          itemBuilder: (_, i) {
                            final image = CachedNetworkImage(
                              imageUrl: images[i],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            );
                            final activeTag = widget.heroTag ??
                                'product-image-${_product!['id']}';
                            final wrapped = i == 0
                                ? Hero(
                                    tag: activeTag,
                                    child: image,
                                  )
                                : image;
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    fullscreenDialog: true,
                                    builder: (_) => ImageZoomPage(
                                      imageUrls: images,
                                      initialIndex: i,
                                    ),
                                  ),
                                );
                              },
                              child: wrapped,
                            );
                          },
                        ),
                        if (images.length > 1)
                          Positioned(
                            bottom: 24,
                            left: 0,
                            right: 0,
                            child: ValueListenableBuilder<int>(
                              valueListenable: _currentImageIndex,
                              builder: (context, current, _) => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: List.generate(
                                  images.length,
                                  (i) => AnimatedContainer(
                                    duration: const Duration(
                                        milliseconds: 220),
                                    curve: Curves.easeOutCubic,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    width: i == current ? 20 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: i == current
                                          ? OrivaColors.gold
                                          : OrivaColors.cream
                                              .withValues(alpha: 0.4),
                                      borderRadius:
                                          BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ),

          // Infos
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_vendor != null) ...[
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: OrivaColors.surface,
                          backgroundImage: _vendor!['avatar_url'] != null
                              ? CachedNetworkImageProvider(
                                  _vendor!['avatar_url'])
                              : null,
                          child: _vendor!['avatar_url'] == null
                              ? const Icon(LucideIcons.store,
                                  size: 14, color: OrivaColors.muted)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _vendor!['display_name'] ?? 'Vendeur',
                            style: OrivaTypography.body(
                                size: 13, color: OrivaColors.muted),
                          ),
                        ),
                        if (_product!['vendor_id'] != null)
                          FollowVendorButton(
                              vendorId: _product!['vendor_id'].toString()),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  Text(
                    _product!['title'] ?? '',
                    style: OrivaTypography.display(
                        size: 30, weight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatPrice(_product!['display_price'] ?? 0),
                            style: OrivaTypography.display(
                                size: 26,
                                color: OrivaColors.gold,
                                weight: FontWeight.w500),
                          ),
                          if (_product!['shipping_fee_estimate'] != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '+ ${_formatPrice(_product!['shipping_fee_estimate'])} de livraison estimée',
                              style: OrivaTypography.body(
                                size: 12,
                                color: OrivaColors.muted,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: outOfStock
                              ? OrivaColors.danger.withValues(alpha: 0.1)
                              : OrivaColors.success
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          outOfStock ? 'Rupture' : '$stock en stock',
                          style: OrivaTypography.body(
                            size: 12,
                            weight: FontWeight.w500,
                            color: outOfStock
                                ? OrivaColors.danger
                                : OrivaColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  ProductRatingSummary(
                    productId: _product!['id'].toString(),
                  ),
                  const SizedBox(height: 32),

                  Text('DESCRIPTION', style: OrivaTypography.label()),
                  const SizedBox(height: 12),
                  Text(
                    _product!['description'] ??
                        'Aucune description disponible.',
                    style: OrivaTypography.body(size: 15),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: EdgeInsets.fromLTRB(
            24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
        decoration: const BoxDecoration(
          color: OrivaColors.black,
          border: Border(top: BorderSide(color: OrivaColors.border)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: outOfStock
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    final images =
                        List<String>.from(_product!['images'] ?? []);
                    ref.read(cartProvider.notifier).addItem(
                          CartItem(
                            id: _product!['id'].toString(),
                            title: _product!['title'] ?? '',
                            price: _product!['display_price'] ?? 0,
                            weightGrams: _product!['weight_grams'] ?? 0,
                            imageUrl:
                                images.isNotEmpty ? images[0] : null,
                            stock: _product!['stock'] ?? 0,
                          ),
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${_product!['title']} ajouté au panier',
                          style: OrivaTypography.body(
                              color: OrivaColors.black),
                        ),
                        backgroundColor: OrivaColors.gold,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        action: SnackBarAction(
                          label: 'Voir panier',
                          textColor: OrivaColors.black,
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .hideCurrentSnackBar();
                            ref
                                .read(homeTabIndexProvider.notifier)
                                .state = 1;
                            context.go('/home');
                          },
                        ),
                      ),
                    );
                  },
            icon: Icon(
                outOfStock ? LucideIcons.x : LucideIcons.shoppingBag,
                size: 18),
            label: Text(
                outOfStock ? 'Rupture de stock' : 'Ajouter au panier'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  outOfStock ? OrivaColors.surface : OrivaColors.gold,
              foregroundColor:
                  outOfStock ? OrivaColors.muted : OrivaColors.black,
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
      ),
    );
  }
}
