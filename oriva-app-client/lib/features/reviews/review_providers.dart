import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'review_models.dart';
import 'review_repository.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository();
});

final reviewStatsProvider = FutureProvider.autoDispose
    .family<ReviewStats, String>((ref, productId) async {
  return ref.read(reviewRepositoryProvider).getStats(productId);
});

final productReviewsProvider = FutureProvider.autoDispose
    .family<List<Review>, String>((ref, productId) async {
  return ref.read(reviewRepositoryProvider).getReviews(productId);
});

final canReviewProvider = FutureProvider.autoDispose
    .family<CanReviewResult, String>((ref, productId) async {
  return ref.read(reviewRepositoryProvider).canReview(productId);
});
