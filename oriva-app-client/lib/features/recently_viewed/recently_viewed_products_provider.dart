import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase/supabase_service.dart';
import 'recently_viewed_provider.dart';

final recentlyViewedProductsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final ids = ref.watch(recentlyViewedProvider);
  if (ids.isEmpty) return [];

  final response = await SupabaseService.client
      .from('products_with_pricing')
      .select()
      .inFilter('id', ids);

  final products = List<Map<String, dynamic>>.from(response);

  products.sort((a, b) {
    final ai = ids.indexOf(a['id'] as String);
    final bi = ids.indexOf(b['id'] as String);
    return ai.compareTo(bi);
  });

  return products;
});
