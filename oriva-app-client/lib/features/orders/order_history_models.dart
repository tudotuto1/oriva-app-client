import 'package:flutter/foundation.dart';

enum OrderStatus {
  paymentPending,
  pending,
  shipped,
  delivered,
  cancelled,
  unknown;

  static OrderStatus fromString(String? raw) {
    switch (raw) {
      case 'payment_pending':
        return OrderStatus.paymentPending;
      case 'pending':
        return OrderStatus.pending;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.unknown;
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.paymentPending:
        return 'En attente de paiement';
      case OrderStatus.pending:
        return 'Confirmée';
      case OrderStatus.shipped:
        return 'Expédiée';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
      case OrderStatus.unknown:
        return 'Inconnu';
    }
  }

  int get step {
    switch (this) {
      case OrderStatus.paymentPending:
        return 0;
      case OrderStatus.pending:
        return 1;
      case OrderStatus.shipped:
        return 2;
      case OrderStatus.delivered:
        return 3;
      default:
        return 0;
    }
  }
}

@immutable
class OrderHistoryItem {
  final String id;
  final String shortId;
  final OrderStatus status;
  final double total;
  final double shippingFee;
  final int itemCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OrderHistoryItem({
    required this.id,
    required this.shortId,
    required this.status,
    required this.total,
    required this.shippingFee,
    required this.itemCount,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderHistoryItem.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    return OrderHistoryItem(
      id: id,
      shortId: id.length >= 8
          ? '#${id.substring(0, 8).toUpperCase()}'
          : '#${id.toUpperCase()}',
      status: OrderStatus.fromString(json['status']?.toString()),
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      shippingFee:
          double.tryParse(json['shipping_fee']?.toString() ?? '0') ?? 0,
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }
}
