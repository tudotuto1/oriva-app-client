import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_theme.dart';

/// Widget générique pour afficher un état d'erreur.
/// N'expose JAMAIS l'exception brute à l'utilisateur.
class OrivaErrorState extends StatelessWidget {
  final String message;
  final String? hint;
  final IconData icon;
  final VoidCallback? onRetry;
  final String retryLabel;

  const OrivaErrorState({
    super.key,
    this.message = 'Impossible de charger.',
    this.hint = 'Vérifie ta connexion et réessaye.',
    this.icon = LucideIcons.cloudOff,
    this.onRetry,
    this.retryLabel = 'Réessayer',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: OrivaColors.danger.withValues(alpha: 0.12),
              ),
              child: Icon(icon,
                  size: 28, color: OrivaColors.danger),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: OrivaTypography.body(
                size: 15,
                weight: FontWeight.w500,
              ),
            ),
            if (hint != null && hint!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                hint!,
                textAlign: TextAlign.center,
                style: OrivaTypography.body(
                    size: 13, color: OrivaColors.muted),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: Text(retryLabel),
                style: OutlinedButton.styleFrom(
                  foregroundColor: OrivaColors.gold,
                  side: BorderSide(
                      color:
                          OrivaColors.gold.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
