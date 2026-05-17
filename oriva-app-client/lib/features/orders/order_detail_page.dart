import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/theme/app_theme.dart';
import 'order_models.dart';
import 'order_providers.dart';
import 'widgets/order_status_badge.dart';
import 'widgets/order_status_timeline.dart';

class OrderDetailPage extends ConsumerWidget {
  final String orderId;
  const OrderDetailPage({super.key, required this.orderId});

  String _formatPrice(num v) {
    final f = NumberFormat('#,###', 'fr_FR');
    return '${f.format(v).replaceAll(',', ' ')} F CFA';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderStreamProvider(orderId));
    final itemsAsync = ref.watch(orderItemsProvider(orderId));
    final dateFmt = DateFormat('d MMM yyyy · HH:mm', 'fr_FR');

    return Scaffold(
      backgroundColor: OrivaColors.black,
      appBar: AppBar(
        title: Text(
          'Commande #${orderId.substring(0, 8).toUpperCase()}',
          style: OrivaTypography.display(size: 18, weight: FontWeight.w500),
        ),
        backgroundColor: OrivaColors.black,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: OrivaColors.cream),
          onPressed: () => context.pop(),
        ),
      ),
      body: orderAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: OrivaColors.gold)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Erreur : $e',
                style: OrivaTypography.body(color: OrivaColors.danger)),
          ),
        ),
        data: (order) {
          if (order == null) {
            return Center(
              child: Text('Commande introuvable',
                  style: OrivaTypography.body(color: OrivaColors.muted)),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header : badge + date
              Row(
                children: [
                  OrderStatusBadge(status: order.status),
                  const Spacer(),
                  Text(
                    dateFmt.format(order.createdAt.toLocal()),
                    style: OrivaTypography.body(
                        size: 12, color: OrivaColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Timeline
              OrderStatusTimeline(status: order.status),
              const SizedBox(height: 24),

              // Articles
              Text('ARTICLES', style: OrivaTypography.label()),
              const SizedBox(height: 12),
              itemsAsync.when(
                loading: () => const Center(
                    child:
                        CircularProgressIndicator(color: OrivaColors.gold)),
                error: (e, _) => Text('Erreur items : $e',
                    style: OrivaTypography.body(color: OrivaColors.danger)),
                data: (items) => Column(
                  children: items
                      .map((it) => _OrderItemTile(
                            item: it,
                            formatPrice: _formatPrice,
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Récap
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: OrivaColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _LineRow(
                        label: 'Sous-total',
                        value: _formatPrice(order.subtotal)),
                    const SizedBox(height: 8),
                    _LineRow(
                        label: 'Livraison',
                        value: order.shippingFee > 0
                            ? _formatPrice(order.shippingFee)
                            : 'Offerte 🎁'),
                    const Divider(color: OrivaColors.border, height: 24),
                    _LineRow(
                        label: 'Total',
                        value: _formatPrice(order.total),
                        bold: true),
                  ],
                ),
              ),

              if (order.shippingAddress != null) ...[
                const SizedBox(height: 24),
                Text('ADRESSE DE LIVRAISON',
                    style: OrivaTypography.label()),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: OrivaColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatAddress(order.shippingAddress!),
                    style: OrivaTypography.body(size: 13),
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  String _formatAddress(Map<String, dynamic> addr) {
    final parts = <String>[];
    void add(String? v) {
      if (v != null && v.toString().trim().isNotEmpty) parts.add(v.trim());
    }

    add(addr['recipient_name']?.toString());
    add(addr['phone']?.toString());
    add(addr['address_line']?.toString());
    add(addr['city']?.toString());
    add(addr['country']?.toString());
    return parts.isEmpty ? 'Adresse non renseignée' : parts.join('\n');
  }
}

class _OrderItemTile extends StatelessWidget {
  final OrderItem item;
  final String Function(num) formatPrice;
  const _OrderItemTile({required this.item, required this.formatPrice});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: OrivaColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 56,
              height: 56,
              child: item.imageSnapshot != null
                  ? CachedNetworkImage(
                      imageUrl: item.imageSnapshot!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                          color: OrivaColors.muted.withValues(alpha: 0.1)),
                      errorWidget: (_, __, ___) => Container(
                        color: OrivaColors.muted.withValues(alpha: 0.1),
                        child: const Icon(LucideIcons.image,
                            size: 20, color: OrivaColors.muted),
                      ),
                    )
                  : Container(
                      color: OrivaColors.muted.withValues(alpha: 0.1),
                      child: const Icon(LucideIcons.image,
                          size: 20, color: OrivaColors.muted),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.titleSnapshot,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: OrivaTypography.body(
                        size: 14, weight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text('${item.quantity} × ${formatPrice(item.priceSnapshot)}',
                    style: OrivaTypography.body(
                        size: 12, color: OrivaColors.muted)),
              ],
            ),
          ),
          Text(formatPrice(item.lineTotal),
              style: OrivaTypography.body(
                  size: 14,
                  color: OrivaColors.gold,
                  weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _LineRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: OrivaTypography.body(
                size: bold ? 15 : 13,
                color: bold ? OrivaColors.cream : OrivaColors.muted,
                weight: bold ? FontWeight.w600 : FontWeight.w400)),
        const Spacer(),
        Text(value,
            style: OrivaTypography.body(
                size: bold ? 16 : 13,
                color: bold ? OrivaColors.gold : OrivaColors.cream,
                weight: bold ? FontWeight.w600 : FontWeight.w500)),
      ],
    );
  }
}
