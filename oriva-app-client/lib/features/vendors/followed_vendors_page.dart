import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/supabase/supabase_service.dart';
import '../../core/theme/app_theme.dart';

class FollowedVendorsPage extends StatefulWidget {
  const FollowedVendorsPage({super.key});

  @override
  State<FollowedVendorsPage> createState() => _FollowedVendorsPageState();
}

class _FollowedVendorsPageState extends State<FollowedVendorsPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _vendors = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = SupabaseService.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final follows = await SupabaseService.client
          .from('vendor_follows')
          .select('vendor_id')
          .eq('follower_id', user.id);
      final ids = List<Map<String, dynamic>>.from(follows)
          .map((e) => e['vendor_id'].toString())
          .toList();
      if (ids.isEmpty) {
        if (mounted) setState(() {
          _vendors = [];
          _loading = false;
        });
        return;
      }
      final profiles = await SupabaseService.client
          .from('profiles')
          .select('id, display_name, avatar_url')
          .inFilter('id', ids);
      if (mounted) {
        setState(() {
          _vendors = List<Map<String, dynamic>>.from(profiles);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Boutiques suivies',
            style: OrivaTypography.display(size: 20, weight: FontWeight.w500)),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: OrivaColors.gold))
          : _vendors.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.store,
                            size: 48, color: OrivaColors.muted),
                        const SizedBox(height: 16),
                        Text('Vous ne suivez aucune boutique.',
                            textAlign: TextAlign.center,
                            style: OrivaTypography.body(
                                size: 14, color: OrivaColors.muted)),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _vendors.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final v = _vendors[i];
                    final name = v['display_name']?.toString() ?? 'Boutique';
                    final avatar = v['avatar_url']?.toString();
                    return GestureDetector(
                      onTap: () => context.push('/vendor/${v['id']}'),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: OrivaColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: OrivaColors.border),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: OrivaColors.surface,
                              backgroundImage:
                                  (avatar != null && avatar.isNotEmpty)
                                      ? CachedNetworkImageProvider(avatar)
                                      : null,
                              child: (avatar == null || avatar.isEmpty)
                                  ? const Icon(LucideIcons.store,
                                      size: 20, color: OrivaColors.muted)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(name,
                                  style: OrivaTypography.body(
                                      size: 15, weight: FontWeight.w600)),
                            ),
                            const Icon(LucideIcons.chevronRight,
                                size: 18, color: OrivaColors.muted),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
