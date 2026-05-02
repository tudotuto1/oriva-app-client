import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_service.dart';

/// Service centralisé pour tous les calculs de pricing.
/// Délègue tout à la DB Postgres pour rester source of truth unique.
class PricingService {
  static const int minimumCartFcfa = 15000;

  static SupabaseClient get _client => SupabaseService.client;

  /// Calcule les frais de livraison pour un panier donné selon son poids total.
  /// Appelle la fonction Postgres calculate_shipping_fee.
  /// Retourne 0 si le poids est invalide (< 1g) ou erreur réseau.
  static Future<int> calculateShippingFee(int totalWeightGrams) async {
    if (totalWeightGrams <= 0) return 0;
    try {
      final response = await _client.rpc(
        'calculate_shipping_fee',
        params: {'p_total_weight_grams': totalWeightGrams},
      );
      if (response is int) return response;
      if (response is num) return response.toInt();
      return 0;
    } catch (e) {
      // Fallback : on retourne 0 mais log l'erreur côté console
      // (l'utilisateur verra "Livraison à confirmer" dans l'UI)
      return 0;
    }
  }
}
