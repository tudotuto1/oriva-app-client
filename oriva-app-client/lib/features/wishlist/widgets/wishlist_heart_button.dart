import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../wishlist_providers.dart';

class WishlistHeartButton extends ConsumerStatefulWidget {
  const WishlistHeartButton({
    super.key,
    required this.productId,
    this.size = 28,
  });

  final String productId;
  final double size;

  @override
  ConsumerState<WishlistHeartButton> createState() =>
      _WishlistHeartButtonState();
}

class _WishlistHeartButtonState
    extends ConsumerState<WishlistHeartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 1.4,
  ).chain(CurveTween(curve: Curves.easeOutBack)).animate(_ctrl);

  bool _busy = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onTap(bool currentlyIn) async {
    if (_busy) return;
    setState(() => _busy = true);
    HapticFeedback.lightImpact();
    _ctrl.forward(from: 0).then((_) => _ctrl.reverse());

    try {
      final repo = ref.read(wishlistRepositoryProvider);
      await repo.toggle(widget.productId, currentlyIn);
      ref.invalidate(wishlistIdsProvider);
      ref.invalidate(wishlistItemsProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connecte-toi pour utiliser la wishlist.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncIds = ref.watch(wishlistIdsProvider);
    final inWishlist =
        asyncIds.value?.contains(widget.productId) ?? false;

    return ScaleTransition(
      scale: _scale,
      child: IconButton(
        onPressed: () => _onTap(inWishlist),
        icon: Icon(
          inWishlist ? Icons.favorite : Icons.favorite_border,
          color: inWishlist
              ? const Color(0xFFC9A96E)
              : const Color(0xFFF5F0E8),
          size: widget.size,
        ),
      ),
    );
  }
}
