import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/supabase/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import 'follow_button.dart';

class VendorPage extends StatefulWidget {
  final String vendorId;
  const VendorPage({super.key, required this.vendorId});

  @override
  State<VendorPage> createState() => _VendorPageState();
}

class _VendorPageState extends State<VendorPage> {
  bool _loading = true;
  Map<String, dynamic>? _vendor;
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final vendor = await SupabaseService.client
          .from('profiles')
          .select('display_name, avatar_url')
          .eq('id', widget.vendorId)
          .maybeSingle();
      final products = await SupabaseService.client
          .from('products_with_pricing')
          .select()
          .eq('vendor_id', widget.vendorId)
          .eq('is_archived', false)
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _vendor = vendor;
          _products = List<Map<String, dynamic>>.from(products);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatPrice(num price) =>
      '${NumberFormat('#,###', 'fr_FR').format(price).replaceAll(',', ' ')} F CFA';

  @override
  Widget build(BuildContext context) {
    final name = _vendor?['display_name']?.toString() ?? 'Boutique';
    final avatar = _vendor?['avatar_url']?.toString();
    return Scaffold(
      appBar: AppBar(
        title: Text(name,
            style: OrivaTypography.display(size: 20, weight: FontWeight.w500)),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: OrivaColors.gold))
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: OrivaColors.surface,
                          backgroundImage: (avatar != null && avatar.isNotEmpty)
                              ? CachedNetworkImageProvider(avatar)
                              : null,
                          child: (avatar == null || avatar.isEmpty)
                              ? const Icon(LucideIcons.store,
                                  color: OrivaColors.muted)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: OrivaTypography.body(
                                      size: 18, weight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                  '${_products.length} produit${_products.length > 1 ? 's' : ''}',
                                  style: OrivaTypography.body(
                                      size: 13, color: OrivaColors.muted)),
                            ],
                          ),
                        ),
                        FollowVendorButton(vendorId: widget.vendorId),
                      ],
                    ),
                  ),
                ),
                if (_products.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text('Aucun produit pour le moment.',
                          style: TextStyle(color: OrivaColors.muted)),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _VendorProductCard(
                            product: _products[i], formatPrice: _formatPrice),
                        childCount: _products.length,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _VendorProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final String Function(num) formatPrice;
  const _VendorProductCard(
      {required this.product, required this.formatPrice});

  @override
  Widget build(BuildContext context) {
    final images = List<String>.from(product['images'] ?? []);
    final firstImage = images.isNotEmpty ? images[0] : null;
    final stock = product['stock'] ?? 0;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('/product/${product['id']}');
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
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(product['title'] ?? '',
                        style: OrivaTypography.body(
                            size: 13, weight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatPrice(product['display_price'] ?? 0),
                            style: OrivaTypography.body(
                                size: 14,
                                color: OrivaColors.gold,
                                weight: FontWeight.w700)),
                        if (stock == 0)
                          Text('Rupture de stock',
                              style: OrivaTypography.body(
                                  size: 10, color: OrivaColors.danger)),
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
