import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../core/pricing/pricing_service.dart';
import '../../core/theme/app_theme.dart';
import '../orders/order_models.dart';
import '../orders/order_providers.dart';
import '../orders/order_repository.dart';
import 'cart_provider.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  String _formatPrice(num price) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return '${formatter.format(price).replaceAll(',', '\u202f')} F CFA';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final cart = ref.read(cartProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  Text(
                    'Mon Panier',
                    style: OrivaTypography.display(
                        size: 28, weight: FontWeight.w500),
                  ),
                  const Spacer(),
                  if (items.isNotEmpty)
                    TextButton(
                      onPressed: () => _confirmClear(context, cart),
                      child: Text(
                        'Vider',
                        style: OrivaTypography.body(
                            size: 13, color: OrivaColors.danger),
                      ),
                    ),
                ],
              ),
            ),

            // ─── Corps
            Expanded(
              child: items.isEmpty
                  ? const _EmptyCart()
                  : ListView.separated(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(
                          color: OrivaColors.border, height: 1),
                      itemBuilder: (context, i) =>
                          _CartItemTile(item: items[i], cart: cart),
                    ),
            ),

            // ─── Récapitulatif + bouton checkout
            if (items.isNotEmpty)
              _CheckoutPanel(
                cart: cart,
                formatPrice: _formatPrice,
              ),
          ],
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context, CartNotifier cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: OrivaColors.card,
        title: Text('Vider le panier ?',
            style: OrivaTypography.body(weight: FontWeight.w600)),
        content: Text('Tous les articles seront retirés.',
            style: OrivaTypography.body(color: OrivaColors.muted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler',
                style: OrivaTypography.body(color: OrivaColors.muted)),
          ),
          TextButton(
            onPressed: () {
              cart.clear();
              Navigator.pop(context);
            },
            child: Text('Vider',
                style: OrivaTypography.body(color: OrivaColors.danger)),
          ),
        ],
      ),
    );
  }
}

// ─── Tuile article ─────────────────────────────────────────────────────────
class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final CartNotifier cart;

  const _CartItemTile({required this.item, required this.cart});

  String _formatPrice(num price) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return '${formatter.format(price).replaceAll(',', '\u202f')} F CFA';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: item.imageUrl!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                        width: 72,
                        height: 72,
                        color: OrivaColors.surface),
                  )
                : Container(
                    width: 72,
                    height: 72,
                    color: OrivaColors.surface,
                    child: const Icon(LucideIcons.image,
                        color: OrivaColors.muted),
                  ),
          ),
          const SizedBox(width: 16),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: OrivaTypography.body(
                      size: 14, weight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatPrice(item.price),
                  style: OrivaTypography.body(
                      size: 14,
                      color: OrivaColors.gold,
                      weight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Contrôles quantité
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: OrivaColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _QtyButton(
                  icon: LucideIcons.minus,
                  onTap: () => cart.decrement(item.id),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '${item.quantity}',
                    style: OrivaTypography.body(
                        size: 15, weight: FontWeight.w600),
                  ),
                ),
                _QtyButton(
                  icon: LucideIcons.plus,
                  onTap: item.quantity < item.stock
                      ? () => cart.increment(item.id)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 14,
          color:
              onTap != null ? OrivaColors.cream : OrivaColors.muted,
        ),
      ),
    );
  }
}

// ─── Panier vide ───────────────────────────────────────────────────────────
class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.shoppingBag,
              size: 64, color: OrivaColors.muted),
          const SizedBox(height: 20),
          Text(
            'Votre panier est vide',
            style: OrivaTypography.display(
                size: 22, weight: FontWeight.w400),
          ),
          const SizedBox(height: 8),
          Text(
            'Découvrez nos produits et ajoutez-en.',
            style: OrivaTypography.body(color: OrivaColors.muted),
          ),
        ],
      ),
    );
  }
}

// ─── Panel checkout ────────────────────────────────────────────────────────
class _CheckoutPanel extends ConsumerStatefulWidget {
  final CartNotifier cart;
  final String Function(num) formatPrice;

  const _CheckoutPanel({
    required this.cart,
    required this.formatPrice,
  });

  @override
  ConsumerState<_CheckoutPanel> createState() => _CheckoutPanelState();
}

class _CheckoutPanelState extends ConsumerState<_CheckoutPanel> {
  int? _shippingFee;
  bool _loadingShipping = false;
  int? _lastFetchedWeight;

  @override
  void initState() {
    super.initState();
    _fetchShipping();
  }

  @override
  void didUpdateWidget(covariant _CheckoutPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetchShipping();
  }

  Future<void> _fetchShipping() async {
    final weight = widget.cart.totalWeightGrams;
    if (weight == _lastFetchedWeight) return; // pas de re-fetch inutile
    _lastFetchedWeight = weight;

    if (weight <= 0) {
      setState(() => _shippingFee = 0);
      return;
    }

    setState(() => _loadingShipping = true);
    final fee = await PricingService.calculateShippingFee(weight);
    if (!mounted) return;
    setState(() {
      _shippingFee = fee;
      _loadingShipping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // On observe le state du panier pour rafraîchir la livraison
    ref.watch(cartProvider);
    // Refetch automatique si poids a changé
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_lastFetchedWeight != widget.cart.totalWeightGrams) {
        _fetchShipping();
      }
    });

    final subtotal = widget.cart.total;
    final shipping = _shippingFee ?? 0;
    final total = subtotal + shipping;

    final belowMinimum = subtotal < PricingService.minimumCartFcfa;
    final missingAmount = PricingService.minimumCartFcfa - subtotal;

    final orderState = ref.watch(createOrderControllerProvider);
    final isLoading = orderState.isLoading;

    ref.listen<AsyncValue<CreateOrderResult?>>(
      createOrderControllerProvider,
      (previous, next) {
        next.whenOrNull(
          data: (result) {
            if (result != null) {
              final orderId = result.primaryOrderId;
              ref.read(createOrderControllerProvider.notifier).reset();
              context.go('/order-confirmation/$orderId');
            }
          },
          error: (err, _) {
            final msg = err is CreateOrderException
                ? err.userMessage
                : 'Erreur lors de la création de la commande.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  msg,
                  style: OrivaTypography.body(color: OrivaColors.cream),
                ),
                backgroundColor: OrivaColors.danger,
                duration: const Duration(seconds: 4),
              ),
            );
            ref.read(createOrderControllerProvider.notifier).reset();
          },
        );
      },
    );

    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).padding.bottom + 20),
      decoration: const BoxDecoration(
        color: OrivaColors.card,
        border: Border(top: BorderSide(color: OrivaColors.border)),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Sous-total',
            value: widget.formatPrice(subtotal),
            isMuted: true,
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Livraison',
            value: _loadingShipping
                ? '…'
                : (shipping > 0
                    ? widget.formatPrice(shipping)
                    : 'À calculer'),
            isMuted: true,
            isGold: false,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: OrivaColors.border, height: 1),
          ),
          _SummaryRow(
            label: 'Total',
            value: widget.formatPrice(total),
            isBold: true,
          ),

          // ─── Message panier minimum
          if (belowMinimum) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: OrivaColors.warning.withValues(alpha: 0.1),
                border:
                    Border.all(color: OrivaColors.warning.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.info,
                      size: 16, color: OrivaColors.warning),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Encore ${widget.formatPrice(missingAmount)} pour atteindre le minimum de commande',
                      style: OrivaTypography.body(
                        size: 12,
                        color: OrivaColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (isLoading || belowMinimum)
                  ? null
                  : () {
                      ref.read(createOrderControllerProvider.notifier).submit();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: OrivaColors.gold,
                foregroundColor: OrivaColors.black,
                disabledBackgroundColor:
                    OrivaColors.surface,
                disabledForegroundColor: OrivaColors.muted,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: OrivaColors.black,
                      ),
                    )
                  : Text(
                      belowMinimum
                          ? 'Continuer mes achats'
                          : 'Commander — ${widget.formatPrice(total)}',
                      style: OrivaTypography.body(
                        weight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMuted;
  final bool isBold;
  final bool isGold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isMuted = false,
    this.isBold = false,
    this.isGold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: OrivaTypography.body(
            size: isBold ? 16 : 14,
            color:
                isMuted ? OrivaColors.muted : OrivaColors.cream,
            weight: isBold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: OrivaTypography.body(
            size: isBold ? 16 : 14,
            color: isGold
                ? OrivaColors.gold
                : isBold
                    ? OrivaColors.gold
                    : isMuted
                        ? OrivaColors.cream
                        : OrivaColors.cream,
            weight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
