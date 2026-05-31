import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/supabase/supabase_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          final destination =
              SupabaseService.isAuthenticated ? '/home' : '/onboarding';
          context.go(destination);
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrivaColors.black,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Image.asset(
                'assets/splash/logo.png',
                width: 240,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            left: 48,
            right: 48,
            bottom: 120,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: _controller.value,
                    minHeight: 3,
                    backgroundColor: const Color(0x26FFFFFF),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        OrivaColors.gold),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
