import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'home_page.dart';
import '../cart/cart_page.dart';
import '../cart/cart_provider.dart';
import '../profile/profile_page.dart';

final homeTabIndexProvider = StateProvider<int>((_) => 0);

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  final _pages = const [HomePage(), CartPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartCountProvider);
    final currentIndex = ref.watch(homeTabIndexProvider);

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: OrivaColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (i) =>
              ref.read(homeTabIndexProvider.notifier).state = i,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.house),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: _AnimatedCartIcon(count: cartCount),
              label: 'Panier',
            ),
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.user),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCartIcon extends StatefulWidget {
  const _AnimatedCartIcon({required this.count});
  final int count;

  @override
  State<_AnimatedCartIcon> createState() => _AnimatedCartIconState();
}

class _AnimatedCartIconState extends State<_AnimatedCartIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 1.25,
  ).chain(CurveTween(curve: Curves.easeOutBack)).animate(_ctrl);

  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _previousCount = widget.count;
  }

  @override
  void didUpdateWidget(covariant _AnimatedCartIcon old) {
    super.didUpdateWidget(old);
    if (widget.count > _previousCount) {
      _ctrl.forward(from: 0).then((_) {
        if (mounted) _ctrl.reverse();
      });
    }
    _previousCount = widget.count;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.count;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        const Icon(LucideIcons.shoppingBag),
        if (count > 0)
          Positioned(
            top: -6,
            right: -8,
            child: ScaleTransition(
              scale: _scale,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: OrivaColors.gold,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: OrivaColors.gold.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: OrivaTypography.body(
                    size: 11,
                    weight: FontWeight.w700,
                    color: OrivaColors.black,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
