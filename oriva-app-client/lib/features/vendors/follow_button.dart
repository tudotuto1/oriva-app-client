import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/supabase/supabase_service.dart';
import '../../core/theme/app_theme.dart';

class FollowVendorButton extends StatefulWidget {
  final String vendorId;
  const FollowVendorButton({super.key, required this.vendorId});

  @override
  State<FollowVendorButton> createState() => _FollowVendorButtonState();
}

class _FollowVendorButtonState extends State<FollowVendorButton> {
  bool _loading = true;
  bool _following = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final user = SupabaseService.currentUser;
    if (user == null || user.id == widget.vendorId) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final rows = await SupabaseService.client
          .from('vendor_follows')
          .select('vendor_id')
          .eq('follower_id', user.id)
          .eq('vendor_id', widget.vendorId)
          .limit(1);
      if (mounted) {
        setState(() {
          _following = (rows as List).isNotEmpty;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle() async {
    final user = SupabaseService.currentUser;
    if (user == null || _busy) return;
    setState(() => _busy = true);
    final wasFollowing = _following;
    setState(() => _following = !wasFollowing);
    try {
      if (wasFollowing) {
        await SupabaseService.client
            .from('vendor_follows')
            .delete()
            .eq('follower_id', user.id)
            .eq('vendor_id', widget.vendorId);
      } else {
        await SupabaseService.client.from('vendor_follows').insert({
          'follower_id': user.id,
          'vendor_id': widget.vendorId,
        });
      }
    } catch (_) {
      if (mounted) setState(() => _following = wasFollowing);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = SupabaseService.currentUser;
    if (_loading || me == null || me.id == widget.vendorId) {
      return const SizedBox.shrink();
    }
    return OutlinedButton.icon(
      onPressed: _busy ? null : _toggle,
      icon: Icon(
        _following ? LucideIcons.check : LucideIcons.plus,
        size: 14,
        color: _following ? OrivaColors.black : OrivaColors.gold,
      ),
      label: Text(
        _following ? 'Suivi' : 'Suivre',
        style: OrivaTypography.body(
          size: 12,
          color: _following ? OrivaColors.black : OrivaColors.gold,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: _following ? OrivaColors.gold : Colors.transparent,
        side: const BorderSide(color: OrivaColors.gold),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
