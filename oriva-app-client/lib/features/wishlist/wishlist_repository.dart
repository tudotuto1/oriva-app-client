import 'package:supabase_flutter/supabase_flutter.dart';

class WishlistRepository {
  WishlistRepository(this._client);
  final SupabaseClient _client;

  // SÉCURITÉ : user_id lu via auth.uid() côté serveur (RLS).
  // Le client envoie SEULEMENT le product_id.
  Future<void> add(String productId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('NOT_AUTHENTICATED');
    await _client.from('wishlists').insert({
      'user_id': user.id,
      'product_id': productId,
    });
  }

  Future<void> remove(String productId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('NOT_AUTHENTICATED');
    await _client
        .from('wishlists')
        .delete()
        .eq('user_id', user.id)
        .eq('product_id', productId);
  }

  // Toggle : add si absent, remove si présent. Idempotent.
  // Retourne true si ajouté, false si retiré.
  Future<bool> toggle(String productId, bool currentlyInWishlist) async {
    if (currentlyInWishlist) {
      await remove(productId);
      return false;
    } else {
      try {
        await add(productId);
        return true;
      } on PostgrestException catch (e) {
        // 23505 = unique_violation : déjà présent (race condition)
        if (e.code == '23505') return true;
        rethrow;
      }
    }
  }

  // Liste des product_id de l'utilisateur (pour cœurs partout)
  Future<Set<String>> fetchMyWishlistIds() async {
    final user = _client.auth.currentUser;
    if (user == null) return {};
    final response = await _client
        .from('wishlists')
        .select('product_id')
        .eq('user_id', user.id);
    return (response as List)
        .map((e) => e['product_id'].toString())
        .toSet();
  }

  // Liste enrichie des produits en wishlist (pour page wishlist)
  Future<List<Map<String, dynamic>>> fetchMyWishlistItems() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    final response = await _client
        .from('wishlists')
        .select('''
          id,
          product_id,
          created_at,
          products!inner(
            id, title, images, price, stock, is_archived,
            vendor_price_fcfa_at_creation
          )
        ''')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    return (response as List).cast<Map<String, dynamic>>();
  }
}
