class UserNotification {
  final String id;
  final String? vendorId;
  final String? buyerId;
  final String? relatedOrderId;
  final String type;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const UserNotification({
    required this.id,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.vendorId,
    this.buyerId,
    this.relatedOrderId,
  });

  factory UserNotification.fromMap(Map<String, dynamic> m) {
    return UserNotification(
      id: m['id'].toString(),
      vendorId: m['vendor_id']?.toString(),
      buyerId: m['buyer_id']?.toString(),
      relatedOrderId: m['related_order_id']?.toString(),
      type: m['type']?.toString() ?? 'unknown',
      message: m['message']?.toString() ?? '',
      isRead: m['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(m['created_at'].toString()),
    );
  }
}
