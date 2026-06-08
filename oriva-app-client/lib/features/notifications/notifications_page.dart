import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../core/supabase/supabase_service.dart';
import 'notification_models.dart';
import 'notification_providers.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  IconData _iconFor(String type) {
    switch (type) {
      case 'order_shipped':
        return LucideIcons.truck;
      case 'order_delivered':
        return LucideIcons.circleCheck;
      case 'order_cancelled':
        return LucideIcons.circleX;
      case 'new_order':
        return LucideIcons.packageOpen;
      default:
        return LucideIcons.bell;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'order_shipped':
        return const Color(0xFF60A5FA);
      case 'order_delivered':
        return const Color(0xFF34D399);
      case 'order_cancelled':
        return OrivaColors.danger;
      default:
        return OrivaColors.gold;
    }
  }

  String _relativeDate(DateTime d) {
    final diff = DateTime.now().difference(d.toLocal());
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inHours < 1) return 'Il y a ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    return DateFormat('d MMM yyyy', 'fr_FR').format(d.toLocal());
  }

  Future<void> _onTapNotif(BuildContext context, WidgetRef ref,
      UserNotification n) async {
    HapticFeedback.lightImpact();
    if (!n.isRead) {
      try {
        await ref.read(notificationRepositoryProvider).markAsRead(n.id);
      } catch (_) {}
    }
    if (!context.mounted) return;
    if (n.relatedOrderId != null) {
      context.push('/order-history');
    }
  }

  Future<void> _markAll(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    try {
      final count =
          await ref.read(notificationRepositoryProvider).markAllAsRead();
      if (!context.mounted) return;
      if (count > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$count notification(s) marquée(s) comme lue(s)',
              style: OrivaTypography.body(color: OrivaColors.black),
            ),
            backgroundColor: OrivaColors.gold,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myNotificationsStreamProvider);
    final unread = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      backgroundColor: OrivaColors.black,
      appBar: AppBar(
        backgroundColor: OrivaColors.black,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: OrivaColors.cream),
          onPressed: () => context.pop(),
        ),
        title: Text('Notifications',
            style:
                OrivaTypography.display(size: 22, weight: FontWeight.w500)),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () => _markAll(context, ref),
              child: Text(
                'Tout lire',
                style: OrivaTypography.body(
                    size: 13, color: OrivaColors.gold),
              ),
            ),
        ],
      ),
      body: async.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: OrivaColors.gold)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.bellOff,
                    size: 48,
                    color: OrivaColors.muted.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text('Aucune notification',
                    style: OrivaTypography.body(
                        size: 16, color: OrivaColors.muted)),
                const SizedBox(height: 8),
                Text('Vos notifications apparaîtront ici.',
                    textAlign: TextAlign.center,
                    style: OrivaTypography.body(
                        size: 13,
                        color: OrivaColors.muted.withValues(alpha: 0.7))),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    try {
                      await SupabaseService.client.auth.refreshSession();
                    } catch (_) {}
                    ref.invalidate(myNotificationsStreamProvider);
                  },
                  child: Text('Réessayer',
                      style: OrivaTypography.body(
                          size: 14, color: OrivaColors.gold)),
                ),
              ],
            ),
          ),
        ),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.bellOff,
                      size: 48,
                      color: OrivaColors.muted.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('Aucune notification',
                      style: OrivaTypography.body(
                          size: 16, color: OrivaColors.muted)),
                  const SizedBox(height: 8),
                  Text(
                    'Vous serez notifié des mises à jour\nde vos commandes ici.',
                    textAlign: TextAlign.center,
                    style: OrivaTypography.body(
                        size: 13,
                        color: OrivaColors.muted.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final n = list[i];
              final color = _colorFor(n.type);
              return InkWell(
                onTap: () => _onTapNotif(context, ref, n),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: n.isRead
                        ? OrivaColors.surface
                        : OrivaColors.gold.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: n.isRead
                          ? OrivaColors.border
                          : OrivaColors.gold.withValues(alpha: 0.25),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.15),
                        ),
                        child: Icon(_iconFor(n.type), color: color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.message,
                              style: OrivaTypography.body(
                                size: 14,
                                weight: n.isRead
                                    ? FontWeight.w400
                                    : FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _relativeDate(n.createdAt),
                              style: OrivaTypography.body(
                                  size: 11, color: OrivaColors.muted),
                            ),
                          ],
                        ),
                      ),
                      if (!n.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8, top: 6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: OrivaColors.gold,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
