import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Pastille « vendeur vérifié ».
/// showLabel=false → icône seule (lignes compactes).
/// showLabel=true  → icône + « Vérifié ».
class VerifiedBadge extends StatelessWidget {
  final bool showLabel;
  final double size;
  const VerifiedBadge({super.key, this.showLabel = false, this.size = 16});

  @override
  Widget build(BuildContext context) {
    final icon = Icon(Icons.verified, size: size, color: OrivaColors.gold);
    if (!showLabel) return icon;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 4),
        Text(
          'Vérifié',
          style: OrivaTypography.body(
              size: 12, color: OrivaColors.gold, weight: FontWeight.w600),
        ),
      ],
    );
  }
}
