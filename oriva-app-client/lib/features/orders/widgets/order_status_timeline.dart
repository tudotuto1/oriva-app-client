import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../order_models.dart';

class OrderStatusTimeline extends StatelessWidget {
  final OrderStatus status;
  const OrderStatusTimeline({super.key, required this.status});

  int get _currentStep {
    switch (status) {
      case OrderStatus.paymentPending:
        return 0;
      case OrderStatus.pending:
        return 1;
      case OrderStatus.shipped:
        return 2;
      case OrderStatus.delivered:
        return 3;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: OrivaColors.danger.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: OrivaColors.danger.withValues(alpha: 0.3), width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.circleX,
                color: OrivaColors.danger, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Commande annulée',
                style: OrivaTypography.body(
                    color: OrivaColors.danger, weight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    final steps = const [
      ('Paiement', LucideIcons.creditCard),
      ('En préparation', LucideIcons.packageOpen),
      ('Expédiée', LucideIcons.truck),
      ('Livrée', LucideIcons.circleCheck),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OrivaColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final isPast = (i ~/ 2) < _currentStep;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: isPast
                    ? OrivaColors.gold
                    : OrivaColors.muted.withValues(alpha: 0.2),
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final reached = stepIndex <= _currentStep;
          final current = stepIndex == _currentStep;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: reached
                      ? OrivaColors.gold
                      : OrivaColors.muted.withValues(alpha: 0.15),
                  border: current
                      ? Border.all(
                          color: OrivaColors.gold.withValues(alpha: 0.4),
                          width: 4)
                      : null,
                ),
                child: Icon(
                  steps[stepIndex].$2,
                  size: 16,
                  color: reached ? OrivaColors.black : OrivaColors.muted,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 64,
                child: Text(
                  steps[stepIndex].$1,
                  textAlign: TextAlign.center,
                  style: OrivaTypography.body(
                    size: 10,
                    color: reached ? OrivaColors.cream : OrivaColors.muted,
                    weight: current ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
