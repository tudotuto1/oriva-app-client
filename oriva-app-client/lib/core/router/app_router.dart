import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/onboarding_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/signup_page.dart';
import '../../features/home/home_shell.dart';
import '../../features/orders/order_confirmation_page.dart';
import '../../features/orders/order_history_page.dart';
import '../../features/payment/payment_page.dart';
import '../../features/product/product_detail_page.dart';
import '../../features/profile/edit_profile_page.dart';
import '../../features/addresses/addresses_page.dart';
import '../../features/addresses/address_form_page.dart';
import '../supabase/supabase_service.dart';
import 'page_transitions.dart';

final appRouter = GoRouter(
  initialLocation: '/onboarding',
  redirect: (context, state) {
    final isAuth = SupabaseService.isAuthenticated;
    final onAuthPage = state.matchedLocation == '/login' ||
        state.matchedLocation == '/signup' ||
        state.matchedLocation == '/onboarding';

    // Si déjà connecté et sur une page auth → redirect vers home
    if (isAuth && onAuthPage) return '/home';

    // Si non connecté et sur une page protégée → redirect vers login
    if (!isAuth && !onAuthPage) return '/onboarding';

    return null;
  },
  routes: [
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
    GoRoute(path: '/home', builder: (context, state) => const HomeShell()),
    GoRoute(
      path: '/product/:id',
      pageBuilder: (context, state) => orivaPageTransition(
        key: state.pageKey,
        child: ProductDetailPage(productId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/order-confirmation/:id',
      pageBuilder: (context, state) => orivaPageTransition(
        key: state.pageKey,
        child: OrderConfirmationPage(
          orderId: state.pathParameters['id']!,
        ),
      ),
    ),
    GoRoute(
      path: '/payment/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        final extra = state.extra;
        final totalFcfa = (extra is Map && extra['totalFcfa'] is int)
            ? extra['totalFcfa'] as int
            : 0;
        return PaymentPage(orderId: orderId, totalFcfa: totalFcfa);
      },
    ),
    GoRoute(
      path: '/order-history',
      builder: (context, state) => const OrderHistoryPage(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      path: '/addresses',
      builder: (_, __) => const AddressesPage(),
    ),
    GoRoute(
      path: '/address/new',
      builder: (_, __) => const AddressFormPage(),
    ),
    GoRoute(
      path: '/address/edit/:id',
      builder: (_, state) =>
          AddressFormPage(addressId: state.pathParameters['id']),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Page introuvable', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Retour à l\'accueil'),
          ),
        ],
      ),
    ),
  ),
);
