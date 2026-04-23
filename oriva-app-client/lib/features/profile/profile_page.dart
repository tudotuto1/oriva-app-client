import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../core/supabase/supabase_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;
    try {
      final data = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      setState(() => _profile = data);
    } catch (_) {}
  }

  Future<void> _logout() async {
    await SupabaseService.client.auth.signOut();
    if (mounted) context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.currentUser;
    final email = user?.email ?? '';
    final name = _profile?['display_name'] ?? email.split('@').first;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mon compte', style: OrivaTypography.display(size: 22, weight: FontWeight.w500)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Avatar + nom
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: OrivaColors.surface,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: OrivaTypography.display(size: 28, weight: FontWeight.w500, color: OrivaColors.gold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: OrivaTypography.body(size: 18, weight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(email, style: OrivaTypography.body(size: 13, color: OrivaColors.muted)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          _buildMenuItem(LucideIcons.package, 'Mes commandes', () {}),
          _buildMenuItem(LucideIcons.mapPin, 'Adresses de livraison', () {}),
          _buildMenuItem(LucideIcons.bell, 'Notifications', () {}),
          _buildMenuItem(LucideIcons.circleHelp, 'Aide & support', () {}),

          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(LucideIcons.logOut, size: 16),
            label: const Text('Se déconnecter'),
            style: OutlinedButton.styleFrom(
              foregroundColor: OrivaColors.danger,
              side: const BorderSide(color: OrivaColors.border),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: OrivaColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OrivaColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: OrivaColors.gold, size: 20),
        title: Text(label, style: OrivaTypography.body(size: 15)),
        trailing: const Icon(LucideIcons.chevronRight, color: OrivaColors.muted, size: 18),
      ),
    );
  }
}
