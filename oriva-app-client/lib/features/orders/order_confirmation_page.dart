import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';

class OrderConfirmationPage extends StatelessWidget {
  final String orderId;

  const OrderConfirmationPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final shortId = orderId.length >= 8
        ? orderId.substring(0, 8).toUpperCase()
        : orderId.toUpperCase();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: OrivaColors.gold.withValues(alpha: 0.15),
                  border: Border.all(color: OrivaColors.gold, width: 1.5),
                ),
                child: const Icon(LucideIcons.check,
                    size: 48, color: OrivaColors.gold),
              ),
              const SizedBox(height: 32),
              Text(
                'Commande passée',
                style: OrivaTypography.display(
                    size: 32, weight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Votre commande est en attente de paiement.\nLe paiement sera bientôt disponible.',
                style: OrivaTypography.body(
                    size: 14, color: OrivaColors.muted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: OrivaColors.card,
                  border: Border.all(color: OrivaColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text('Numéro de commande',
                        style: OrivaTypography.label()),
                    const SizedBox(height: 6),
                    Text(
                      '#$shortId',
                      style: OrivaTypography.body(
                        size: 18,
                        weight: FontWeight.w700,
                        color: OrivaColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Continuer mes achats'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text(
                  'Retour à l\'accueil',
                  style: OrivaTypography.body(
                      size: 14, color: OrivaColors.muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
