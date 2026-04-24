import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  List<Map<String, dynamic>> _products = [];
  String _searchQuery = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchController.text;
    if (q == _searchQuery) return;
    setState(() => _searchQuery = q);
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    try {
      final response = await SupabaseService.client
          .from('products')
          .select()
          .eq('is_archived', false)
          .order('created_at', ascending: false);
      setState(() {
        _products = List<Map<String, dynamic>>.from(response);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredProducts {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _products;
    return _products
        .where((p) => (p['title'] ?? '').toString().toLowerCase().contains(q))
        .toList();
  }

  List<Map<String, dynamic>> get _featuredProducts =>
      _products.take(5).toList();

  String _formatPrice(num price) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return '${formatter.format(price).replaceAll(',', ' ')} F CFA';
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
              // Header
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
                      Text('ORIVA', style: OrivaTypography.display(size: 20, weight: FontWeight.w500)),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(LucideIcons.bell),
                      ),
                    ],
                  ),
                ),
              ),

              // Titre
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Découvrir', style: OrivaTypography.display(size: 40, weight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(
                        'Produits sélectionnés avec soin',
                        style: OrivaTypography.body(color: OrivaColors.muted),
                      ),
                    ],
                  ),
                ),
              ),

              // Recherche
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un produit…',
                      prefixIcon: const Icon(LucideIcons.search, size: 18),
                      suffixIcon: _searchQuery.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(LucideIcons.x, size: 16),
                              onPressed: () => _searchController.clear(),
                            ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Carrousel nouveautés
              if (!_loading && _searchQuery.isEmpty && _featuredProducts.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                    child: Text(
                      'NOUVEAUTÉS',
                      style: OrivaTypography.label(color: OrivaColors.gold),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _FeaturedCarousel(
                    products: _featuredProducts,
                    formatPrice: _formatPrice,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],

              // Grille produits
              if (_loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: OrivaColors.gold)),
                )
              else if (_filteredProducts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isEmpty ? LucideIcons.packageOpen : LucideIcons.searchX,
                          size: 48,
                          color: OrivaColors.muted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Aucun produit pour le moment'
                              : 'Aucun résultat pour « $_searchQuery »',
                          style: OrivaTypography.body(color: OrivaColors.muted),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

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
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: firstImage != null
                    ? CachedNetworkImage(
                        imageUrl: firstImage,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: OrivaColors.surface),
                        errorWidget: (_, __, ___) => Container(
                          color: OrivaColors.surface,
                          child: const Icon(LucideIcons.imageOff, color: OrivaColors.muted),
                        ),
                      )
                    : Container(
                        color: OrivaColors.surface,
                        child: const Icon(LucideIcons.image, color: OrivaColors.muted),
                      ),
              ),
            ),

            // Infos
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'] ?? '',
                    style: OrivaTypography.body(size: 14, weight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatPrice(product['price'] ?? 0),
                    style: OrivaTypography.body(size: 15, color: OrivaColors.gold, weight: FontWeight.w600),
                  ),
                  if (stock == 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Rupture',
                      style: OrivaTypography.body(size: 11, color: OrivaColors.danger),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final String Function(num) formatPrice;

  const _FeaturedCarousel({required this.products, required this.formatPrice});

  @override
  State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel> {
  final _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.products.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) {
              final product = widget.products[i];
              final images = List<String>.from(product['images'] ?? []);
              final firstImage = images.isNotEmpty ? images[0] : null;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () => context.push('/product/${product['id']}'),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (firstImage != null)
                          CachedNetworkImage(
                            imageUrl: firstImage,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: OrivaColors.surface),
                            errorWidget: (_, __, ___) => Container(color: OrivaColors.surface),
                          )
                        else
                          Container(color: OrivaColors.surface),
                        // Gradient noir bas → transparent haut
                        const Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [OrivaColors.black, Colors.transparent],
                                stops: [0.0, 0.7],
                              ),
                            ),
                          ),
                        ),
                        // Overlay texte
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                product['title'] ?? '',
                                style: OrivaTypography.display(
                                  size: 22,
                                  weight: FontWeight.w500,
                                  color: OrivaColors.gold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.formatPrice(product['price'] ?? 0),
                                style: OrivaTypography.body(
                                  size: 15,
                                  weight: FontWeight.w600,
                                  color: OrivaColors.gold,
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
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.products.length, (i) {
            final active = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: active ? 18 : 6,
              decoration: BoxDecoration(
                color: active ? OrivaColors.gold : OrivaColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
