import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/supabase/supabase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  bool _loading = true;
  int _carouselIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredProducts = query.isEmpty
          ? _allProducts
          : _allProducts
              .where((p) =>
                  (p['title'] as String? ?? '')
                      .toLowerCase()
                      .contains(query) ||
                  (p['description'] as String? ?? '')
                      .toLowerCase()
                      .contains(query))
              .toList();
    });
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
        _filteredProducts = products;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  String _formatPrice(num price) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return '${formatter.format(price).replaceAll(',', '\u202f')} F CFA';
  }

  // Les 5 produits les plus récents avec image pour le carrousel
  List<Map<String, dynamic>> get _carouselProducts {
    return _allProducts
        .where((p) {
          final images = List<String>.from(p['images'] ?? []);
          return images.isNotEmpty;
        })
        .take(5)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
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
                            onTap: () =>
                                context.push('/product/${product['id']}'),
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
                                    CachedNetworkImage(
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

              // ─── Barre de recherche
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un produit…',
                      prefixIcon:
                          const Icon(LucideIcons.search, size: 18),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(LucideIcons.x, size: 16),
                              onPressed: () {
                                _searchController.clear();
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
                        _searchController.text.isEmpty
                            ? 'Tous les produits'
                            : 'Résultats',
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
                            '${_filteredProducts.length}',
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
                const SliverFillRemaining(
                  child: Center(
                    child:
                        CircularProgressIndicator(color: OrivaColors.gold),
                  ),
                )
              else if (_filteredProducts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.packageOpen,
                            size: 48, color: OrivaColors.muted),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Aucun produit pour le moment'
                              : 'Aucun résultat pour "${_searchController.text}"',
                          style: OrivaTypography.body(
                              color: OrivaColors.muted),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
                        product: _filteredProducts[i],
                        formatPrice: _formatPrice,
                      ),
                      childCount: _filteredProducts.length,
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
      onTap: () => context.push('/product/${product['id']}'),
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
                    ? CachedNetworkImage(
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
