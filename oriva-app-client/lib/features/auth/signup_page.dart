import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../core/supabase/supabase_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _showPassword = false;
  bool _loading = false;

  Future<void> _handleSignup() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty) return;

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Le mot de passe doit faire au moins 6 caractères.', style: OrivaTypography.body()),
          backgroundColor: OrivaColors.danger,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await SupabaseService.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {'display_name': _nameController.text.trim()},
      );

      if (response.user != null) {
        // Le trigger SQL crée le profil automatiquement
        if (mounted) context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'inscription. Réessayez.', style: OrivaTypography.body()),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Créer un compte', style: OrivaTypography.display(size: 36)),
              const SizedBox(height: 8),
              Text(
                'Rejoignez la communauté Oriva',
                style: OrivaTypography.body(color: OrivaColors.muted),
              ),
              const SizedBox(height: 40),

              Text('NOM', style: OrivaTypography.label()),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Votre nom'),
              ),
              const SizedBox(height: 20),

              Text('EMAIL', style: OrivaTypography.label()),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(hintText: 'vous@email.com'),
              ),
              const SizedBox(height: 20),

              Text('MOT DE PASSE', style: OrivaTypography.label()),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  hintText: 'Min. 6 caractères',
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
                  onPressed: _loading ? null : _handleSignup,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: OrivaColors.black),
                        )
                      : const Text('Créer mon compte'),
                ),
              ),

              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: RichText(
                    text: TextSpan(
                      style: OrivaTypography.body(color: OrivaColors.muted),
                      children: [
                        const TextSpan(text: 'Déjà un compte ? '),
                        TextSpan(
                          text: 'Se connecter',
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
