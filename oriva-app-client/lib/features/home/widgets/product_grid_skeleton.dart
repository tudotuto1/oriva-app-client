import 'package:flutter/material.dart';
import '../../../core/widgets/oriva_shimmer.dart';

class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({super.key, this.itemCount = 6});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return OrivaShimmer(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: itemCount,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: ShimmerBox(
                  width: double.infinity,
                  height: double.infinity,
                  radius: 12,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: ShimmerBox(width: 120, height: 14),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: ShimmerBox(width: 80, height: 12),
              ),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
