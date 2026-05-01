import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'home_page.dart';
import '../cart/cart_page.dart';
import '../cart/cart_provider.dart';
import '../profile/profile_page.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _currentIndex = 0;

  final _pages = const [HomePage(), CartPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartCountProvider);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: OrivaColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.house),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(LucideIcons.shoppingBag),
                  if (cartCount > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: OrivaColors.gold,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            cartCount > 9 ? '9+' : '$cartCount',
                            style: OrivaTypography.body(
                              size: 10,
                              weight: FontWeight.w700,
                              color: OrivaColors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
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
