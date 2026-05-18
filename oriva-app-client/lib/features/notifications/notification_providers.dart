import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_models.dart';
import 'notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final myNotificationsStreamProvider =
    StreamProvider.autoDispose<List<UserNotification>>((ref) {
  return ref.read(notificationRepositoryProvider).watchMyNotifications();
});

/// Compteur de notifications non lues (réactif au stream).
final unreadNotificationCountProvider =
    Provider.autoDispose<int>((ref) {
  final async = ref.watch(myNotificationsStreamProvider);
  return async.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});
