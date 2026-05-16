import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/theme/app_theme.dart';
import 'review_models.dart';
import 'review_providers.dart';
import 'review_repository.dart';
import 'widgets/star_rating.dart';

class ReviewsPage extends ConsumerWidget {
  final String productId;
  const ReviewsPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(reviewStatsProvider(productId));
    final reviewsAsync = ref.watch(productReviewsProvider(productId));
    final canReviewAsync = ref.watch(canReviewProvider(productId));

    return Scaffold(
      backgroundColor: OrivaColors.black,
      appBar: AppBar(
        title: Text('Avis', style: OrivaTypography.display(size: 22)),
        backgroundColor: OrivaColors.black,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: OrivaColors.cream),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        color: OrivaColors.gold,
        onRefresh: () async {
          ref.invalidate(reviewStatsProvider(productId));
          ref.invalidate(productReviewsProvider(productId));
          ref.invalidate(canReviewProvider(productId));
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // Header stats
            statsAsync.when(
              loading: () => const SizedBox(height: 100),
              error: (_, __) => const SizedBox.shrink(),
              data: (stats) => _StatsHeader(stats: stats),
            ),
            const SizedBox(height: 24),

            // Bouton "Laisser un avis" si éligible
            canReviewAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (can) {
                if (can.canReview) {
                  return _CreateReviewButton(productId: productId);
                }
                if (can.reason == 'already_reviewed' ||
                    can.reason == 'not_purchased_or_not_delivered') {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: OrivaColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.info,
                              size: 18, color: OrivaColors.muted),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              can.userMessage,
                              style: OrivaTypography.body(
                                  size: 13, color: OrivaColors.muted),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Liste des avis
            reviewsAsync.when(
              loading: () => const Center(
                  child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child:
                    CircularProgressIndicator(color: OrivaColors.gold),
              )),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Erreur de chargement : $e',
                  style: OrivaTypography.body(color: OrivaColors.danger),
                ),
              ),
              data: (reviews) {
                if (reviews.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(LucideIcons.messageSquare,
                              size: 36,
                              color:
                                  OrivaColors.muted.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          Text(
                            'Aucun avis pour le moment',
                            style: OrivaTypography.body(
                                color: OrivaColors.muted),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: reviews
                      .map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ReviewCard(review: r),
                          ))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  final ReviewStats stats;
  const _StatsHeader({required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.reviewCount == 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: OrivaColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(LucideIcons.star,
                size: 40,
                color: OrivaColors.muted.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(
              'Soyez le premier à laisser un avis',
              style: OrivaTypography.body(
                  size: 14, color: OrivaColors.muted),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OrivaColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: OrivaColors.gold.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                stats.averageRating.toStringAsFixed(1),
                style: OrivaTypography.display(
                  size: 44,
                  color: OrivaColors.gold,
                  weight: FontWeight.w500,
                ),
              ),
              StarRating(rating: stats.averageRating, size: 14),
              const SizedBox(height: 4),
              Text(
                '${stats.reviewCount} avis',
                style: OrivaTypography.body(
                    size: 12, color: OrivaColors.muted),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                _RatingBar(label: '5', count: stats.count5, total: stats.reviewCount),
                _RatingBar(label: '4', count: stats.count4, total: stats.reviewCount),
                _RatingBar(label: '3', count: stats.count3, total: stats.reviewCount),
                _RatingBar(label: '2', count: stats.count2, total: stats.reviewCount),
                _RatingBar(label: '1', count: stats.count1, total: stats.reviewCount),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  const _RatingBar({required this.label, required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    final ratio = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            child: Text(label,
                style: OrivaTypography.body(
                    size: 11, color: OrivaColors.muted)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: OrivaColors.muted.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation(OrivaColors.gold),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 24,
            child: Text('$count',
                textAlign: TextAlign.end,
                style: OrivaTypography.body(
                    size: 11, color: OrivaColors.muted)),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('d MMM yyyy', 'fr_FR');
    final name = review.buyerDisplayName?.trim().isNotEmpty == true
        ? review.buyerDisplayName!
        : 'Client Oriva';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OrivaColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: OrivaColors.black,
                backgroundImage: review.buyerAvatarUrl != null
                    ? CachedNetworkImageProvider(review.buyerAvatarUrl!)
                    : null,
                child: review.buyerAvatarUrl == null
                    ? const Icon(LucideIcons.user,
                        size: 16, color: OrivaColors.muted)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: OrivaTypography.body(
                            size: 14, weight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(
                      dateFmt.format(review.createdAt.toLocal()),
                      style: OrivaTypography.body(
                          size: 11, color: OrivaColors.muted),
                    ),
                  ],
                ),
              ),
              StarRating(rating: review.rating.toDouble(), size: 14),
            ],
          ),
          if (review.comment != null && review.comment!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: OrivaTypography.body(size: 14),
            ),
          ],
        ],
      ),
    );
  }
}

class _CreateReviewButton extends ConsumerWidget {
  final String productId;
  const _CreateReviewButton({required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _open(context, ref),
          icon: const Icon(LucideIcons.star, size: 18),
          label: const Text('Laisser un avis'),
          style: ElevatedButton.styleFrom(
            backgroundColor: OrivaColors.gold,
            foregroundColor: OrivaColors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    final created = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: OrivaColors.black,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CreateReviewSheet(productId: productId),
    );
    if (created == true && context.mounted) {
      ref.invalidate(reviewStatsProvider(productId));
      ref.invalidate(productReviewsProvider(productId));
      ref.invalidate(canReviewProvider(productId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Merci pour votre avis !',
              style: OrivaTypography.body(color: OrivaColors.black)),
          backgroundColor: OrivaColors.gold,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _CreateReviewSheet extends ConsumerStatefulWidget {
  final String productId;
  const _CreateReviewSheet({required this.productId});

  @override
  ConsumerState<_CreateReviewSheet> createState() => _CreateReviewSheetState();
}

class _CreateReviewSheetState extends ConsumerState<_CreateReviewSheet> {
  int _rating = 0;
  final _commentCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating < 1) {
      setState(() => _error = 'Sélectionnez une note.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(reviewRepositoryProvider).createReview(
            productId: widget.productId,
            rating: _rating,
            comment: _commentCtrl.text.trim().isEmpty
                ? null
                : _commentCtrl.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      final msg = e.toString();
      String userMsg = 'Une erreur est survenue.';
      if (msg.contains('ALREADY_REVIEWED')) {
        userMsg = 'Vous avez déjà laissé un avis.';
      } else if (msg.contains('NOT_PURCHASED_OR_NOT_DELIVERED')) {
        userMsg = 'Vous pourrez laisser un avis une fois la commande livrée.';
      } else if (msg.contains('NOT_AUTHENTICATED')) {
        userMsg = 'Connectez-vous pour laisser un avis.';
      } else if (msg.contains('INVALID_RATING')) {
        userMsg = 'Note invalide.';
      }
      setState(() {
        _submitting = false;
        _error = userMsg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: OrivaColors.muted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Votre avis',
              style:
                  OrivaTypography.display(size: 24, weight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Aidez les autres clients en partageant votre expérience.',
              style:
                  OrivaTypography.body(size: 13, color: OrivaColors.muted)),
          const SizedBox(height: 24),
          Center(
            child: InteractiveStarRating(
              currentRating: _rating,
              onChanged: (v) => setState(() {
                _rating = v;
                _error = null;
              }),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _commentCtrl,
            maxLines: 4,
            maxLength: 500,
            style: OrivaTypography.body(),
            decoration: InputDecoration(
              hintText: 'Votre commentaire (facultatif)…',
              hintStyle: OrivaTypography.body(color: OrivaColors.muted),
              filled: true,
              fillColor: OrivaColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              counterStyle: OrivaTypography.body(
                  size: 11, color: OrivaColors.muted),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!,
                style: OrivaTypography.body(
                    size: 13, color: OrivaColors.danger)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: OrivaColors.gold,
                foregroundColor: OrivaColors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: OrivaColors.black),
                    )
                  : const Text("Publier l'avis"),
            ),
          ),
        ],
      ),
    );
  }
}
