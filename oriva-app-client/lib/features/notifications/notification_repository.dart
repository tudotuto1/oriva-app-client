import '../../core/supabase/supabase_service.dart';
import 'notification_models.dart';

class NotificationRepository {
  final _client = SupabaseService.client;

  /// Stream live des notifications du buyer connecté.
  Stream<List<UserNotification>> watchMyNotifications() {
    final user = SupabaseService.currentUser;
    if (user == null) {
      return Stream.value(const []);
    }
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('buyer_id', user.id)
        .order('created_at', ascending: false)
        .map((rows) => rows
            .map((m) => UserNotification.fromMap(Map<String, dynamic>.from(m)))
            .toList());
  }

  Future<void> markAsRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  Future<int> markAllAsRead() async {
    final user = SupabaseService.currentUser;
    if (user == null) return 0;
    final res = await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('buyer_id', user.id)
        .eq('is_read', false)
        .select('id');
    return (res as List).length;
  }
}
