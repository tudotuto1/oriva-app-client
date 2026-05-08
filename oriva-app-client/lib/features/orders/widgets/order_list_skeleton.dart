import 'package:flutter/material.dart';
import '../../../core/widgets/oriva_shimmer.dart';

class OrderListSkeleton extends StatelessWidget {
  const OrderListSkeleton({super.key, this.itemCount = 4});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return OrivaShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBox(width: 90, height: 16),
                  ShimmerBox(width: 70, height: 22, radius: 12),
                ],
              ),
              SizedBox(height: 16),
              ShimmerBox(width: double.infinity, height: 4, radius: 2),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBox(width: 60, height: 12),
                  ShimmerBox(width: 80, height: 14),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
