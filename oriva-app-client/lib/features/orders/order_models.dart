enum OrderStatus {
  paymentPending,
  pending,
  shipped,
  delivered,
  cancelled;

  static OrderStatus fromString(String value) {
    switch (value) {
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
        throw ArgumentError('Statut commande inconnu : $value');
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.paymentPending:
        return 'En attente de paiement';
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.shipped:
        return 'Expédiée';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
    }
  }
}

class Order {
  final String id;
  final String buyerId;
  final String vendorId;
  final OrderStatus status;
  final num subtotal;
  final num shippingFee;
  final num total;
  final String? buyerEmail;
  final Map<String, dynamic>? shippingAddress;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.id,
    required this.buyerId,
    required this.vendorId,
    required this.status,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
    this.buyerEmail,
    this.shippingAddress,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        buyerId: json['buyer_id'] as String,
        vendorId: json['vendor_id'] as String,
        status: OrderStatus.fromString(json['status'] as String),
        subtotal: json['subtotal'] as num,
        shippingFee: json['shipping_fee'] as num,
        total: json['total'] as num,
        buyerEmail: json['buyer_email'] as String?,
        shippingAddress: json['shipping_address'] as Map<String, dynamic>?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
}

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final num priceSnapshot;
  final String titleSnapshot;
  final String? imageSnapshot;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.priceSnapshot,
    required this.titleSnapshot,
    this.imageSnapshot,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json['id'] as String,
        orderId: json['order_id'] as String,
        productId: json['product_id'] as String,
        quantity: json['quantity'] as int,
        priceSnapshot: json['price_snapshot'] as num,
        titleSnapshot: json['title_snapshot'] as String,
        imageSnapshot: json['image_snapshot'] as String?,
      );

  num get lineTotal => priceSnapshot * quantity;
}

class CreateOrderResult {
  final List<String> orderIds;
  final num totalAmount;
  final int orderCount;

  const CreateOrderResult({
    required this.orderIds,
    required this.totalAmount,
    required this.orderCount,
  });

  factory CreateOrderResult.fromJson(Map<String, dynamic> json) =>
      CreateOrderResult(
        orderIds: (json['order_ids'] as List).cast<String>(),
        totalAmount: json['total_amount'] as num,
        orderCount: json['order_count'] as int,
      );

  String get primaryOrderId => orderIds.first;
}
