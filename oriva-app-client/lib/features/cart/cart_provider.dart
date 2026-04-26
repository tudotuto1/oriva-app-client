import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Modèle CartItem ───────────────────────────────────────────────────────
class CartItem {
  final String id;
  final String title;
  final num price;
  final String? imageUrl;
  final int stock;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    this.imageUrl,
    required this.stock,
    this.quantity = 1,
  });

  CartItem copyWith({int? quantity}) => CartItem(
        id: id,
        title: title,
        price: price,
        imageUrl: imageUrl,
        stock: stock,
        quantity: quantity ?? this.quantity,
      );
}

// ─── Notifier ──────────────────────────────────────────────────────────────
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addItem(CartItem newItem) {
    final idx = state.indexWhere((e) => e.id == newItem.id);
    if (idx >= 0) {
      // Déjà dans le panier — incrémenter si stock disponible
      final existing = state[idx];
      if (existing.quantity < existing.stock) {
        state = [
          for (final e in state)
            if (e.id == newItem.id)
              e.copyWith(quantity: e.quantity + 1)
            else
              e,
        ];
      }
    } else {
      state = [...state, newItem];
    }
  }

  void increment(String id) {
    state = [
      for (final e in state)
        if (e.id == id && e.quantity < e.stock)
          e.copyWith(quantity: e.quantity + 1)
        else
          e,
    ];
  }

  void decrement(String id) {
    final item =
        state.firstWhere((e) => e.id == id, orElse: () => throw Exception());
    if (item.quantity <= 1) {
      remove(id);
    } else {
      state = [
        for (final e in state)
          if (e.id == id) e.copyWith(quantity: e.quantity - 1) else e,
      ];
    }
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList();
  }

  void clear() => state = [];

  // ─── Getters utiles
  num get total => state.fold(0, (sum, e) => sum + e.price * e.quantity);
  int get itemCount => state.fold(0, (sum, e) => sum + e.quantity);
  bool contains(String id) => state.any((e) => e.id == id);
}

// ─── Provider global ───────────────────────────────────────────────────────
final cartProvider =
    NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

// Provider dérivé — juste le nombre d'articles (pour le badge)
// Bug fix : on watch cartProvider (le state) et non cartProvider.notifier,
// sinon le Provider ne se rebuild jamais et le badge reste à 0.
final cartCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold<int>(0, (sum, e) => sum + e.quantity);
});
