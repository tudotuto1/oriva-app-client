import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kKey = 'recently_viewed_ids';
const _kMax = 10;

class RecentlyViewedNotifier extends StateNotifier<List<String>> {
  RecentlyViewedNotifier() : super(const []) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_kKey) ?? [];
    state = ids;
  }

  Future<void> add(String productId) async {
    final updated = [productId, ...state.where((id) => id != productId)]
        .take(_kMax)
        .toList();
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kKey, updated);
  }

  Future<void> clear() async {
    state = const [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
  }
}

final recentlyViewedProvider =
    StateNotifierProvider<RecentlyViewedNotifier, List<String>>(
  (ref) => RecentlyViewedNotifier(),
);
