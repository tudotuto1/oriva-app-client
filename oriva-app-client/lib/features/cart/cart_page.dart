import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panier', style: OrivaTypography.display(size: 22, weight: FontWeight.w500)),
        centerTitle: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: OrivaColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(LucideIcons.shoppingBag, size: 36, color: OrivaColors.muted),
              ),
              const SizedBox(height: 24),
              Text('Votre panier est vide', style: OrivaTypography.display(size: 24, weight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text(
                'Ajoutez des produits pour commencer',
                style: OrivaTypography.body(color: OrivaColors.muted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
