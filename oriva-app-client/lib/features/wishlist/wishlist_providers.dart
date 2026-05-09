import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'wishlist_repository.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepository(Supabase.instance.client);
});

// IDs des produits en wishlist (pour cœurs visibles partout)
final wishlistIdsProvider =
    FutureProvider.autoDispose<Set<String>>((ref) async {
  final repo = ref.read(wishlistRepositoryProvider);
  return repo.fetchMyWishlistIds();
});

// Liste enrichie (page wishlist)
final wishlistItemsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.read(wishlistRepositoryProvider);
  return repo.fetchMyWishlistItems();
});
