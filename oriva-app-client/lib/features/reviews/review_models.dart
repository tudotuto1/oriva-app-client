class Review {
  final String id;
  final String productId;
  final String buyerId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String? buyerDisplayName;
  final String? buyerAvatarUrl;

  const Review({
    required this.id,
    required this.productId,
    required this.buyerId,
    required this.rating,
    required this.createdAt,
    this.comment,
    this.buyerDisplayName,
    this.buyerAvatarUrl,
  });

  factory Review.fromMap(Map<String, dynamic> m, {Map<String, dynamic>? buyer}) {
    return Review(
      id: m['id'].toString(),
      productId: m['product_id'].toString(),
      buyerId: m['buyer_id'].toString(),
      rating: (m['rating'] as num).toInt(),
      comment: m['comment'] as String?,
      createdAt: DateTime.parse(m['created_at'].toString()),
      buyerDisplayName: buyer?['display_name'] as String?,
      buyerAvatarUrl: buyer?['avatar_url'] as String?,
    );
  }
}

class ReviewStats {
  final String productId;
  final int reviewCount;
  final double averageRating;
  final int count5;
  final int count4;
  final int count3;
  final int count2;
  final int count1;

  const ReviewStats({
    required this.productId,
    required this.reviewCount,
    required this.averageRating,
    required this.count5,
    required this.count4,
    required this.count3,
    required this.count2,
    required this.count1,
  });

  factory ReviewStats.empty(String productId) => ReviewStats(
        productId: productId,
        reviewCount: 0,
        averageRating: 0,
        count5: 0,
        count4: 0,
        count3: 0,
        count2: 0,
        count1: 0,
      );

  factory ReviewStats.fromMap(Map<String, dynamic> m) {
    return ReviewStats(
      productId: m['product_id'].toString(),
      reviewCount: (m['review_count'] as num?)?.toInt() ?? 0,
      averageRating: (m['average_rating'] as num?)?.toDouble() ?? 0,
      count5: (m['count_5'] as num?)?.toInt() ?? 0,
      count4: (m['count_4'] as num?)?.toInt() ?? 0,
      count3: (m['count_3'] as num?)?.toInt() ?? 0,
      count2: (m['count_2'] as num?)?.toInt() ?? 0,
      count1: (m['count_1'] as num?)?.toInt() ?? 0,
    );
  }
}

class CanReviewResult {
  final bool canReview;
  final String? reason;

  const CanReviewResult({required this.canReview, this.reason});

  factory CanReviewResult.fromMap(Map<String, dynamic> m) {
    return CanReviewResult(
      canReview: m['can_review'] as bool? ?? false,
      reason: m['reason'] as String?,
    );
  }

  String get userMessage {
    switch (reason) {
      case 'not_authenticated':
        return 'Connectez-vous pour laisser un avis.';
      case 'not_purchased_or_not_delivered':
        return 'Vous pourrez laisser un avis une fois votre commande livrée.';
      case 'already_reviewed':
        return 'Vous avez déjà laissé un avis pour ce produit.';
      default:
        return '';
    }
  }
}
