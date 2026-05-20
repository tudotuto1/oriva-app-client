import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/supabase/supabase_service.dart';
import '../categories/category_providers.dart';
import '../categories/widgets/category_chips.dart';
import '../recently_viewed/widgets/recently_viewed_carousel.dart';
import 'search_providers.dart';
import 'widgets/product_grid_skeleton.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  List<Map<String, dynamic>> _allProducts = [];
  bool _loading = true;
  int _carouselIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 250),
      () {
        if (!mounted) return;
        ref.read(searchQueryProvider.notifier).state = value.trim();
      },
    );
    setState(() {}); // refresh suffix icon visibility
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    try {
      final response = await SupabaseService.client
          .from('products_with_pricing')
          .select()
          .order('created_at', ascending: false);
      final products = List<Map<String, dynamic>>.from(response);
      setState(() {
        _allProducts = products;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _resetFilters() {
    _searchController.clear();
    _searchDebounce?.cancel();
    ref.read(searchQueryProvider.notifier).state = '';
    ref.read(selectedCategoryIdProvider.notifier).state = null;
    setState(() {});
  }

  String _formatPrice(num price) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return '${formatter.format(price).replaceAll(',', ' ')} F CFA';
  }

  List<Map<String, dynamic>> get _carouselProducts {
    return _allProducts
        .where((p) {
          final images = List<String>.from(p['images'] ?? []);
          return images.isNotEmpty;
        })
        .take(5)
        .toList();
  }

  List<Map<String, dynamic>> _applyFilters({
    required String query,
    required String? categoryId,
  }) {
    final q = query.toLowerCase();
    return _allProducts.where((p) {
      if (categoryId != null) {
        final pid = p['category_id']?.toString();
        if (pid != categoryId) return false;
      }
      if (q.isNotEmpty) {
        final title = (p['title'] as String? ?? '').toLowerCase();
        final desc = (p['description'] as String? ?? '').toLowerCase();
        if (!title.contains(q) && !desc.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final selectedCatId = ref.watch(selectedCategoryIdProvider);
    final filtered = _applyFilters(query: query, categoryId: selectedCatId);
    final hasActiveFilter = query.isNotEmpty || selectedCatId != null;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: OrivaColors.gold,
          backgroundColor: OrivaColors.card,
          onRefresh: _loadProducts,
          child: CustomScrollView(
            slivers: [
              // ─── Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: OrivaColors.gold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'O',
                            style: OrivaTypography.display(
                              size: 20,
                              weight: FontWeight.w700,
                              color: OrivaColors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'ORIVA',
                        style: OrivaTypography.display(
                            size: 20, weight: FontWeight.w500),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(LucideIcons.bell),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Titre
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Découvrir',
                        style: OrivaTypography.display(
                            size: 38, weight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Produits sélectionnés avec soin',
                        style: OrivaTypography.body(color: OrivaColors.muted),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Carrousel nouveautés
              if (!_loading && _carouselProducts.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Nouveautés',
                              style: OrivaTypography.label(),
                            ),
                            // Indicateurs du carrousel
                            Row(
                              children: List.generate(
                                _carouselProducts.length,
                                (i) => AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 3),
                                  width: i == _carouselIndex ? 18 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: i == _carouselIndex
                                        ? OrivaColors.gold
                                        : OrivaColors.muted
                                            .withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      CarouselSlider.builder(
                        itemCount: _carouselProducts.length,
                        options: CarouselOptions(
                          height: 200,
                          viewportFraction: 0.85,
                          enlargeCenterPage: true,
                          enlargeFactor: 0.15,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 4),
                          autoPlayAnimationDuration:
                              const Duration(milliseconds: 600),
                          autoPlayCurve: Curves.easeInOut,
                          onPageChanged: (i, _) =>
                              setState(() => _carouselIndex = i),
                        ),
                        itemBuilder: (context, i, _) {
                          final product = _carouselProducts[i];
                          final images =
                              List<String>.from(product['images'] ?? []);
                          return GestureDetector(
                            onTap: () => context.push(
                              '/product/${product['id']}',
                              extra: 'product-carousel-${product['id']}',
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: OrivaColors.border),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Hero(
                                      tag:
                                          'product-carousel-${product['id']}',
                                      child: CachedNetworkImage(
                                        imageUrl: images[0],
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => Container(
                                            color: OrivaColors.surface),
                                        errorWidget: (_, __, ___) => Container(
                                          color: OrivaColors.surface,
                                          child: const Icon(LucideIcons.image,
                                              color: OrivaColors.muted),
                                        ),
                                      ),
                                    ),
                                    // Overlay gradient + infos
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              OrivaColors.black
                                                  .withValues(alpha: 0.85),
                                            ],
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                product['title'] ?? '',
                                                style: OrivaTypography.body(
                                                  size: 16,
                                                  weight: FontWeight.w600,
                                                  color: OrivaColors.cream,
                                                ),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _formatPrice(
                                                  product['display_price'] ?? 0),
                                              style: OrivaTypography.body(
                                                size: 15,
                                                color: OrivaColors.gold,
                                                weight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ],

              // ─── Vu récemment
              const SliverToBoxAdapter(
                child: RecentlyViewedCarousel(),
              ),

              // ─── Catégories chips
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              const SliverToBoxAdapter(child: CategoryChipsBar()),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ─── Barre de recherche
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un produit…',
                      prefixIcon:
                          const Icon(LucideIcons.search, size: 18),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(LucideIcons.x, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                _searchDebounce?.cancel();
                                ref
                                    .read(searchQueryProvider.notifier)
                                    .state = '';
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // ─── Titre section + compteur résultats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                  child: Row(
                    children: [
                      Text(
                        hasActiveFilter ? 'Résultats' : 'Tous les produits',
                        style: OrivaTypography.label(),
                      ),
                      const SizedBox(width: 8),
                      if (!_loading)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                OrivaColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${filtered.length}',
                            style: OrivaTypography.body(
                                size: 12, color: OrivaColors.gold),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ─── Grille produits
              if (_loading)
                const SliverToBoxAdapter(
                  child: ProductGridSkeleton(),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.packageOpen,
                              size: 48, color: OrivaColors.muted),
                          const SizedBox(height: 16),
                          Text(
                            hasActiveFilter
                                ? 'Aucun produit ne correspond aux filtres'
                                : 'Aucun produit pour le moment',
                            style: OrivaTypography.body(
                                color: OrivaColors.muted),
                            textAlign: TextAlign.center,
                          ),
                          if (hasActiveFilter) ...[
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: _resetFilters,
                              icon: const Icon(LucideIcons.x,
                                  size: 16, color: OrivaColors.gold),
                              label: Text(
                                'Effacer les filtres',
                                style: OrivaTypography.body(
                                    size: 14, color: OrivaColors.gold),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.65,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _ProductCard(
                        product: filtered[i],
                        formatPrice: _formatPrice,
                      ),
                      childCount: filtered.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Carte produit ─────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final String Function(num) formatPrice;

  const _ProductCard({required this.product, required this.formatPrice});

  @override
  Widget build(BuildContext context) {
    final images = List<String>.from(product['images'] ?? []);
    final firstImage = images.isNotEmpty ? images[0] : null;
    final stock = product['stock'] ?? 0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push(
          '/product/${product['id']}',
          extra: 'product-grid-${product['id']}',
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: OrivaColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: OrivaColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: firstImage != null
                    ? Hero(
                        tag: 'product-grid-${product['id']}',
                        child: CachedNetworkImage(
                          imageUrl: firstImage,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (_, __) =>
                              Container(color: OrivaColors.surface),
                          errorWidget: (_, __, ___) => Container(
                            color: OrivaColors.surface,
                            child: const Icon(LucideIcons.imageOff,
                                color: OrivaColors.muted),
                          ),
                        ),
                      )
                    : Container(
                        color: OrivaColors.surface,
                        child: const Center(
                          child: Icon(LucideIcons.image,
                              color: OrivaColors.muted),
                        ),
                      ),
              ),
            ),

            // Infos
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product['title'] ?? '',
                      style: OrivaTypography.body(
                          size: 13, weight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatPrice(product['display_price'] ?? 0),
                          style: OrivaTypography.body(
                            size: 14,
                            color: OrivaColors.gold,
                            weight: FontWeight.w700,
                          ),
                        ),
                        if (stock == 0)
                          Text(
                            'Rupture de stock',
                            style: OrivaTypography.body(
                                size: 10, color: OrivaColors.danger),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
