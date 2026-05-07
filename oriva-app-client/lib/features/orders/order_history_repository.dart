import 'package:supabase_flutter/supabase_flutter.dart';
import 'order_history_models.dart';

class OrderHistoryRepository {
  OrderHistoryRepository(this._client);
  final SupabaseClient _client;

  Future<List<OrderHistoryItem>> fetchMyOrders() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('orders')
        .select('''
          id,
          status,
          total,
          shipping_fee,
          created_at,
          updated_at,
          order_items(count)
        ''')
        .eq('buyer_id', user.id)
        .order('created_at', ascending: false);

    return (response as List).map((row) {
      final itemCount = (row['order_items'] as List?)?.fold<int>(
            0,
            (sum, e) => sum + ((e['count'] as num?)?.toInt() ?? 0),
          ) ??
          0;
      return OrderHistoryItem.fromJson({...row, 'item_count': itemCount});
    }).toList();
  }
}
