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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
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
                    decoration: const InputDecoration(
                      hintText: 'Rechercher un produit…',
                      prefixIcon: Icon(LucideIcons.search, size: 18),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Grille produits
              if (_loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: OrivaColors.gold)),
                )
              else if (_products.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.packageOpen, size: 48, color: OrivaColors.muted),
                        const SizedBox(height: 16),
                        Text('Aucun produit pour le moment', style: OrivaTypography.body(color: OrivaColors.muted)),
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
                        product: _products[i],
                        formatPrice: _formatPrice,
                      ),
                      childCount: _products.length,
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
