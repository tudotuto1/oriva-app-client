import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';

class ShareProductButton extends StatelessWidget {
  final Map<String, dynamic> product;
  final String? vendorName;
  final double size;

  const ShareProductButton({
    super.key,
    required this.product,
    this.vendorName,
    this.size = 22,
  });

  // Page produit publique (aperçu riche WhatsApp + image).
  static const String _shareBaseUrl =
      'https://oclpkzmpaaurqkefbbij.supabase.co/functions/v1/p';

  String _formatPrice(num price) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return '${formatter.format(price).replaceAll(',', ' ')} F CFA';
  }

  String _buildShareText() {
    final title = product['title']?.toString() ?? 'Produit';
    final displayPrice = product['display_price'];
    final shippingFee = product['shipping_fee_estimate'];
    final description = product['description']?.toString();
    final id = product['id']?.toString();

    final lines = <String>[
      '✨ Découvrez « $title » sur Oriva',
    ];

    if (displayPrice != null) {
      lines.add('💰 ${_formatPrice(displayPrice)}');
    }
    if (shippingFee != null) {
      lines.add('📦 Livraison estimée : ${_formatPrice(shippingFee)}');
    }
    if (vendorName != null && vendorName!.isNotEmpty) {
      lines.add('🛍️ Vendu par $vendorName');
    }
    if (description != null && description.trim().isNotEmpty) {
      final shortDesc = description.length > 140
          ? '${description.substring(0, 140).trim()}…'
          : description.trim();
      lines.add('');
      lines.add(shortDesc);
    }
    if (id != null && id.isNotEmpty) {
      lines.add('');
      lines.add('👉 Voir le produit :');
      lines.add('$_shareBaseUrl?id=$id');
    }
    lines.add('');
    lines.add('— Oriva, marketplace premium Burkina Faso 🇧🇫');

    return lines.join('\n');
  }

  Future<void> _handleShare(BuildContext context) async {
    HapticFeedback.lightImpact();
    final text = _buildShareText();
    final title = product['title']?.toString() ?? 'Produit Oriva';

    if (kIsWeb) {
      // Flutter Web → fallback clipboard
      await Clipboard.setData(ClipboardData(text: text));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Texte copié — collez-le où vous voulez !',
            style: OrivaTypography.body(color: OrivaColors.black),
          ),
          backgroundColor: OrivaColors.gold,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // iOS / Android → share sheet natif
    try {
      await Share.share(text, subject: title);
    } catch (e) {
      // Fallback ultime si Share échoue (rare)
      await Clipboard.setData(ClipboardData(text: text));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Texte copié dans le presse-papier',
            style: OrivaTypography.body(color: OrivaColors.black),
          ),
          backgroundColor: OrivaColors.gold,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: OrivaColors.black.withValues(alpha: 0.6),
      child: IconButton(
        icon: Icon(LucideIcons.share2,
            color: OrivaColors.cream, size: size),
        onPressed: () => _handleShare(context),
        tooltip: 'Partager',
      ),
    );
  }
}
