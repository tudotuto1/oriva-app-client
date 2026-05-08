import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'category_models.dart';

final categoriesProvider =
    FutureProvider<List<Category>>((ref) async {
  final response = await Supabase.instance.client
      .from('categories')
      .select('id, slug, name_fr, icon_name, display_order')
      .eq('is_active', true)
      .order('display_order', ascending: true);
  return (response as List)
      .map((e) => Category.fromJson(e as Map<String, dynamic>))
      .toList();
});

final selectedCategoryIdProvider = StateProvider<String?>((_) => null);
