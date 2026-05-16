import '../../core/supabase/supabase_service.dart';
import 'review_models.dart';

class ReviewRepository {
  final _client = SupabaseService.client;

  Future<ReviewStats> getStats(String productId) async {
    try {
      final res = await _client
          .from('product_review_stats')
          .select()
          .eq('product_id', productId)
          .maybeSingle();
      if (res == null) return ReviewStats.empty(productId);
      return ReviewStats.fromMap(res);
    } catch (_) {
      return ReviewStats.empty(productId);
    }
  }

  Future<List<Review>> getReviews(String productId) async {
    final reviewsData = await _client
        .from('reviews')
        .select()
        .eq('product_id', productId)
        .order('created_at', ascending: false);

    final list = (reviewsData as List).cast<Map<String, dynamic>>();
    if (list.isEmpty) return [];

    // Fetch profiles séparément
    final buyerIds = list.map((r) => r['buyer_id'].toString()).toSet().toList();
    final profilesData = await _client
        .from('profiles')
        .select('id, display_name, avatar_url')
        .inFilter('id', buyerIds);

    final profilesMap = <String, Map<String, dynamic>>{};
    for (final p in (profilesData as List).cast<Map<String, dynamic>>()) {
      profilesMap[p['id'].toString()] = p;
    }

    return list
        .map((r) => Review.fromMap(r, buyer: profilesMap[r['buyer_id'].toString()]))
        .toList();
  }

  Future<CanReviewResult> canReview(String productId) async {
    try {
      final res = await _client
          .rpc('can_review', params: {'p_product_id': productId});
      if (res == null) {
        return const CanReviewResult(canReview: false);
      }
      return CanReviewResult.fromMap(Map<String, dynamic>.from(res as Map));
    } catch (_) {
      return const CanReviewResult(canReview: false);
    }
  }

  /// Lance une exception avec le code d'erreur en cas d'échec
  Future<String> createReview({
    required String productId,
    required int rating,
    String? comment,
  }) async {
    final res = await _client.rpc('create_review', params: {
      'p_product_id': productId,
      'p_rating': rating,
      'p_comment': comment,
    });
    final map = Map<String, dynamic>.from(res as Map);
    return map['review_id'].toString();
  }
}
