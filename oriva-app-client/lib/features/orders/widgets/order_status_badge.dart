import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../order_models.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;
  final bool compact;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  ({Color bg, Color fg, IconData icon}) _styleFor(OrderStatus s) {
    switch (s) {
      case OrderStatus.paymentPending:
        return (
          bg: OrivaColors.muted.withValues(alpha: 0.15),
          fg: OrivaColors.muted,
          icon: LucideIcons.clock,
        );
      case OrderStatus.pending:
        return (
          bg: OrivaColors.gold.withValues(alpha: 0.15),
          fg: OrivaColors.gold,
          icon: LucideIcons.packageOpen,
        );
      case OrderStatus.shipped:
        return (
          bg: const Color(0xFF3B82F6).withValues(alpha: 0.15),
          fg: const Color(0xFF60A5FA),
          icon: LucideIcons.truck,
        );
      case OrderStatus.delivered:
        return (
          bg: const Color(0xFF10B981).withValues(alpha: 0.15),
          fg: const Color(0xFF34D399),
          icon: LucideIcons.circleCheck,
        );
      case OrderStatus.cancelled:
        return (
          bg: OrivaColors.danger.withValues(alpha: 0.15),
          fg: OrivaColors.danger,
          icon: LucideIcons.circleX,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _styleFor(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: compact ? 12 : 14, color: s.fg),
          SizedBox(width: compact ? 4 : 6),
          Text(
            status.label,
            style: OrivaTypography.body(
              size: compact ? 11 : 12,
              color: s.fg,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
