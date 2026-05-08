import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../category_providers.dart';

class CategoryChipsBar extends ConsumerWidget {
  const CategoryChipsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCats = ref.watch(categoriesProvider);
    final selectedId = ref.watch(selectedCategoryIdProvider);

    return SizedBox(
      height: 44,
      child: asyncCats.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
        data: (cats) {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cats.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              if (i == 0) {
                return _Chip(
                  label: 'Toutes',
                  icon: LucideIcons.layoutGrid,
                  selected: selectedId == null,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(selectedCategoryIdProvider.notifier).state = null;
                  },
                );
              }
              final cat = cats[i - 1];
              return _Chip(
                label: cat.nameFr,
                icon: _iconFor(cat.iconName),
                selected: selectedId == cat.id,
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(selectedCategoryIdProvider.notifier).state = cat.id;
                },
              );
            },
          );
        },
      ),
    );
  }

  IconData _iconFor(String? name) {
    switch (name) {
      case 'shirt':
        return LucideIcons.shirt;
      case 'sparkles':
        return LucideIcons.sparkles;
      case 'home':
        return LucideIcons.house;
      case 'cpu':
        return LucideIcons.cpu;
      case 'smartphone':
        return LucideIcons.smartphone;
      case 'gem':
        return LucideIcons.gem;
      case 'shopping-bag':
        return LucideIcons.shoppingBag;
      case 'dumbbell':
        return LucideIcons.dumbbell;
      case 'baby':
        return LucideIcons.baby;
      case 'heart-pulse':
        return LucideIcons.heartPulse;
      default:
        return LucideIcons.tag;
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFC9A96E);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? gold : const Color(0xFF111111),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? gold : const Color(0xFF2A2A2A),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected
                  ? const Color(0xFF080808)
                  : const Color(0xFFC9A96E),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF080808)
                    : const Color(0xFFF5F0E8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
