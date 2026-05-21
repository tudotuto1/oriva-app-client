import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Widget générique pour afficher un état vide.
class OrivaEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const OrivaEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 48,
                color: OrivaColors.muted.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: OrivaTypography.body(
                size: 15,
                weight: FontWeight.w500,
                color: OrivaColors.cream,
              ),
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: OrivaTypography.body(
                    size: 13,
                    color:
                        OrivaColors.muted.withValues(alpha: 0.85)),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
