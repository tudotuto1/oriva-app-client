import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Modèle CartItem ───────────────────────────────────────────────────────
class CartItem {
  final String id;
  final String title;
  final num price;            // display_price (prix client final)
  final int weightGrams;      // NOUVEAU — pour calcul livraison panier
  final String? imageUrl;
  final int stock;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.weightGrams,
    this.imageUrl,
    required this.stock,
    this.quantity = 1,
  });

  CartItem copyWith({int? quantity}) => CartItem(
        id: id,
        title: title,
        price: price,
        weightGrams: weightGrams,
        imageUrl: imageUrl,
        stock: stock,
        quantity: quantity ?? this.quantity,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'weightGrams': weightGrams,
        'imageUrl': imageUrl,
        'stock': stock,
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
        id: j['id'] as String,
        title: j['title'] as String,
        price: j['price'] as num,
        weightGrams: (j['weightGrams'] as num).toInt(),
        imageUrl: j['imageUrl'] as String?,
        stock: (j['stock'] as num).toInt(),
        quantity: (j['quantity'] as num).toInt(),
      );
}

// ─── Notifier ──────────────────────────────────────────────────────────────
class CartNotifier extends Notifier<List<CartItem>> {
  static const _prefsKey = 'oriva_cart_v1';

  @override
  List<CartItem> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw) as List<dynamic>;
      final items = decoded
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();
      if (items.isNotEmpty) {
        state = items;
        ref.read(cartRestoredProvider.notifier).state = true;
      }
    } catch (_) {
      // panier corrompu → ignoré
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode(state.map((e) => e.toJson()).toList()),
      );
    } catch (_) {
      // stockage indisponible → ignoré
    }
  }

  void addItem(CartItem newItem) {
    final idx = state.indexWhere((e) => e.id == newItem.id);
    if (idx >= 0) {
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
    _save();
  }

  void increment(String id) {
    state = [
      for (final e in state)
        if (e.id == id && e.quantity < e.stock)
          e.copyWith(quantity: e.quantity + 1)
        else
          e,
    ];
    _save();
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
    _save();
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList();
    _save();
  }

  void clear() {
    state = [];
    _save();
  }

  // ─── Getters utiles
  num get total => state.fold(0, (sum, e) => sum + e.price * e.quantity);
  int get itemCount => state.fold(0, (sum, e) => sum + e.quantity);
  int get totalWeightGrams =>
      state.fold(0, (sum, e) => sum + e.weightGrams * e.quantity);
  bool contains(String id) => state.any((e) => e.id == id);
}

// ─── Provider global ───────────────────────────────────────────────────────
final cartProvider =
    NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

final cartCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold<int>(0, (sum, e) => sum + e.quantity);
});

final cartRestoredProvider = StateProvider<bool>((_) => false);
