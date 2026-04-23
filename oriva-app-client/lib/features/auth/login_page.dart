import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../core/supabase/supabase_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _loading = false;

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    setState(() => _loading = true);

    try {
      await SupabaseService.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email ou mot de passe incorrect.', style: OrivaTypography.body()),
            backgroundColor: OrivaColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/onboarding'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text('Connexion', style: OrivaTypography.display(size: 40)),
              const SizedBox(height: 8),
              Text(
                'Retrouvez vos produits préférés',
                style: OrivaTypography.body(color: OrivaColors.muted),
              ),
              const SizedBox(height: 48),

              Text('EMAIL', style: OrivaTypography.label()),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(hintText: 'vous@email.com'),
              ),
              const SizedBox(height: 24),

              Text('MOT DE PASSE', style: OrivaTypography.label()),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? LucideIcons.eyeOff : LucideIcons.eye, size: 18),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleLogin,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: OrivaColors.black,
                          ),
                        )
                      : const Text('Se connecter'),
                ),
              ),

              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/signup'),
                  child: RichText(
                    text: TextSpan(
                      style: OrivaTypography.body(color: OrivaColors.muted),
                      children: [
                        const TextSpan(text: 'Pas encore de compte ? '),
                        TextSpan(
                          text: 'Créer un compte',
                          style: OrivaTypography.body(color: OrivaColors.gold, weight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
