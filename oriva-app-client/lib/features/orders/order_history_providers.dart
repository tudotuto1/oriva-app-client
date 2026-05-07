import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'order_history_models.dart';
import 'order_history_repository.dart';

final orderHistoryRepositoryProvider =
    Provider<OrderHistoryRepository>((ref) {
  return OrderHistoryRepository(Supabase.instance.client);
});

final orderHistoryProvider =
    FutureProvider.autoDispose<List<OrderHistoryItem>>((ref) async {
  final repo = ref.read(orderHistoryRepositoryProvider);
  return repo.fetchMyOrders();
});
