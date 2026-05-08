import 'package:flutter/foundation.dart';

@immutable
class Category {
  final String id;
  final String slug;
  final String nameFr;
  final String? iconName;
  final int displayOrder;

  const Category({
    required this.id,
    required this.slug,
    required this.nameFr,
    this.iconName,
    required this.displayOrder,
  });

  factory Category.fromJson(Map<String, dynamic> j) {
    return Category(
      id: j['id'].toString(),
      slug: j['slug']?.toString() ?? '',
      nameFr: j['name_fr']?.toString() ?? '',
      iconName: j['icon_name']?.toString(),
      displayOrder: (j['display_order'] as num?)?.toInt() ?? 0,
    );
  }
}
