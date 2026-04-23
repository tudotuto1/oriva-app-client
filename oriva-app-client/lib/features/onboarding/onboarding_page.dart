import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_Slide> _slides = const [
    _Slide(
      icon: LucideIcons.sparkles,
      title: 'Bienvenue\nsur Oriva',
      subtitle: 'La marketplace premium pour découvrir les meilleurs produits locaux.',
    ),
    _Slide(
      icon: LucideIcons.shoppingBag,
      title: 'Achetez en\ntoute sécurité',
      subtitle: 'Paiement Orange Money intégré. Vos données sont protégées.',
    ),
    _Slide(
      icon: LucideIcons.truck,
      title: 'Suivi en\ntemps réel',
      subtitle: 'Recevez des notifications à chaque étape de votre commande.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Logo
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: OrivaColors.gold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'O',
                        style: OrivaTypography.display(size: 20, weight: FontWeight.w700, color: OrivaColors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('ORIVA', style: OrivaTypography.display(size: 18, weight: FontWeight.w500)),
                ],
              ),
            ),

            // Slides
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) => _buildSlide(_slides[i]),
              ),
            ),

            // Indicateurs
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _currentPage ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentPage ? OrivaColors.gold : OrivaColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            // Boutons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _slides.length - 1) {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                          );
                        } else {
                          context.go('/signup');
                        }
                      },
                      child: Text(_currentPage == _slides.length - 1 ? 'Commencer' : 'Suivant'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      'J\'ai déjà un compte',
                      style: OrivaTypography.body(color: OrivaColors.muted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(_Slide slide) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: OrivaColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: OrivaColors.gold.withValues(alpha: 0.3)),
            ),
            child: Icon(slide.icon, color: OrivaColors.gold, size: 36),
          ),
          const SizedBox(height: 48),
          Text(slide.title, style: OrivaTypography.display(size: 44, weight: FontWeight.w500)),
          const SizedBox(height: 24),
          Text(
            slide.subtitle,
            style: OrivaTypography.body(size: 16, color: OrivaColors.muted),
          ),
        ],
      ),
    );
  }
}

class _Slide {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Slide({required this.icon, required this.title, required this.subtitle});
}
