import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase/supabase_service.dart';
import '../cart/cart_provider.dart';
import 'order_models.dart';

class CreateOrderException implements Exception {
  final String code;
  final String? productId;
  final String? extra;
  final String userMessage;

  const CreateOrderException({
    required this.code,
    required this.userMessage,
    this.productId,
    this.extra,
  });

  @override
  String toString() => 'CreateOrderException($code): $userMessage';
}

class OrderRepository {
  final SupabaseClient _client;

  OrderRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  Future<CreateOrderResult> createOrder(List<CartItem> items) async {
    if (items.isEmpty) {
      throw const CreateOrderException(
        code: 'EMPTY_CART',
        userMessage: 'Votre panier est vide.',
      );
    }

    final payload = items
        .map((e) => {'product_id': e.id, 'quantity': e.quantity})
        .toList();

    try {
      final response = await _client.rpc(
        'create_order',
        params: {'p_items': payload},
      );

      if (response == null) {
        throw const CreateOrderException(
          code: 'EMPTY_RESPONSE',
          userMessage:
              'Erreur inattendue : aucune réponse du serveur. Réessayez.',
        );
      }

      return CreateOrderResult.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    } on PostgrestException catch (e) {
      throw _parseError(e.message);
    } on CreateOrderException {
      rethrow;
    } catch (e) {
      throw CreateOrderException(
        code: 'UNKNOWN',
        userMessage: 'Erreur inattendue : ${e.toString()}',
      );
    }
  }

  CreateOrderException _parseError(String rawMessage) {
    final parts = rawMessage.split(':');
    final code = parts.first.trim();

    switch (code) {
      case 'NOT_AUTHENTICATED':
        return const CreateOrderException(
          code: 'NOT_AUTHENTICATED',
          userMessage: 'Vous devez être connecté pour passer commande.',
        );
      case 'EMPTY_CART':
        return const CreateOrderException(
          code: 'EMPTY_CART',
          userMessage: 'Votre panier est vide.',
        );
      case 'INVALID_QUANTITY':
        return CreateOrderException(
          code: code,
          productId: parts.length > 1 ? parts[1].trim() : null,
          userMessage: 'Quantité invalide pour un des produits.',
        );
      case 'PRODUCT_NOT_FOUND':
        return CreateOrderException(
          code: code,
          productId: parts.length > 1 ? parts[1].trim() : null,
          userMessage:
              'Un produit de votre panier n\'est plus disponible. Veuillez le retirer.',
        );
      case 'PRODUCT_ARCHIVED':
        return CreateOrderException(
          code: code,
          productId: parts.length > 1 ? parts[1].trim() : null,
          userMessage:
              'Un produit a été retiré de la vente. Veuillez le retirer du panier.',
        );
      case 'OUT_OF_STOCK':
        final productId = parts.length > 1 ? parts[1].trim() : null;
        final stock = parts.length > 2 ? parts[2].trim() : '?';
        return CreateOrderException(
          code: code,
          productId: productId,
          extra: stock,
          userMessage:
              'Stock insuffisant. Il ne reste que $stock unité(s) disponible(s).',
        );
      case 'MISSING_VENDOR_PRICE_CNY':
        return CreateOrderException(
          code: code,
          productId: parts.length > 1 ? parts[1].trim() : null,
          userMessage:
              'Un produit du panier n\'a pas encore son prix configuré. Réessayez dans un instant.',
        );
      case 'MISSING_WEIGHT':
        return CreateOrderException(
          code: code,
          productId: parts.length > 1 ? parts[1].trim() : null,
          userMessage:
              'Un produit du panier n\'a pas son poids configuré. Veuillez le retirer.',
        );
      case 'INVALID_CURRENCY':
        return CreateOrderException(
          code: code,
          productId: parts.length > 1 ? parts[1].trim() : null,
          userMessage:
              'Un produit a une configuration invalide. Veuillez le retirer du panier.',
        );
      case 'CART_BELOW_MINIMUM':
        // Format : CART_BELOW_MINIMUM:<vendor_id>:<subtotal>:<minimum>
        final subtotal = parts.length > 2 ? parts[2].trim() : '?';
        final minimum = parts.length > 3 ? parts[3].trim() : '15000';
        return CreateOrderException(
          code: code,
          extra: '$subtotal:$minimum',
          userMessage:
              'Votre panier est trop petit (sous-total : $subtotal FCFA). Le minimum est de $minimum FCFA.',
        );
      case 'CANNOT_BUY_OWN_PRODUCT':
        return CreateOrderException(
          code: code,
          productId: parts.length > 1 ? parts[1].trim() : null,
          userMessage: 'Vous ne pouvez pas acheter vos propres produits.',
        );
      default:
        return const CreateOrderException(
          code: 'UNKNOWN',
          userMessage:
              'Erreur lors de la création de la commande. Réessayez.',
        );
    }
  }
}
