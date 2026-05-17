import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'order_providers.dart';
import 'widgets/order_status_badge.dart';

class MyOrdersPage extends ConsumerWidget {
  const MyOrdersPage({super.key});

  String _formatPrice(num v) {
    final f = NumberFormat('#,###', 'fr_FR');
    return '${f.format(v).replaceAll(',', ' ')} F CFA';
  }

  String _shortId(String id) => id.substring(0, 8).toUpperCase();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(myOrdersStreamProvider);
    final dateFmt = DateFormat('d MMM yyyy · HH:mm', 'fr_FR');

    return Scaffold(
      backgroundColor: OrivaColors.black,
      appBar: AppBar(
        title: Text('Mes commandes',
            style: OrivaTypography.display(size: 22, weight: FontWeight.w500)),
        backgroundColor: OrivaColors.black,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: OrivaColors.cream),
          onPressed: () => context.pop(),
        ),
      ),
      body: ordersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: OrivaColors.gold),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Erreur de chargement : $e',
              textAlign: TextAlign.center,
              style: OrivaTypography.body(color: OrivaColors.danger),
            ),
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.packageOpen,
                      size: 48,
                      color: OrivaColors.muted.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('Aucune commande',
                      style: OrivaTypography.body(
                          size: 16, color: OrivaColors.muted)),
                  const SizedBox(height: 8),
                  Text(
                    'Vos prochaines commandes apparaîtront ici.',
                    style: OrivaTypography.body(
                        size: 13,
                        color: OrivaColors.muted.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final o = orders[i];
              return InkWell(
                onTap: () => context.push('/order-history/${o.id}'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: OrivaColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: OrivaColors.gold.withValues(alpha: 0.1),
                        width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('#${_shortId(o.id)}',
                              style: OrivaTypography.body(
                                  size: 13,
                                  color: OrivaColors.muted,
                                  weight: FontWeight.w500)),
                          const Spacer(),
                          OrderStatusBadge(status: o.status, compact: true),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dateFmt.format(o.createdAt.toLocal()),
                        style: OrivaTypography.body(
                            size: 12,
                            color: OrivaColors.muted.withValues(alpha: 0.7)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(_formatPrice(o.total),
                              style: OrivaTypography.display(
                                  size: 20,
                                  color: OrivaColors.gold,
                                  weight: FontWeight.w500)),
                          const Spacer(),
                          const Icon(LucideIcons.chevronRight,
                              size: 18, color: OrivaColors.muted),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
