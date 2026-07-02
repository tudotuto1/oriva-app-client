import 'package:flutter/material.dart';

/// Palette couleurs Oriva (nom FR → couleur).
const Map<String, Color> orivaColorSwatches = {
  'rouge': Color(0xFFDC2626),
  'jaune': Color(0xFFEAB308),
  'vert': Color(0xFF16A34A),
  'marron': Color(0xFF92400E),
  'bleu': Color(0xFF2563EB),
  'violet': Color(0xFF7C3AED),
  'orange': Color(0xFFEA580C),
  'noir': Color(0xFF111111),
  'blanc': Color(0xFFFFFFFF),
  'rose': Color(0xFFEC4899),
  'gris': Color(0xFF6B7280),
};

Color orivaSwatch(String name) =>
    orivaColorSwatches[name.toLowerCase()] ?? const Color(0xFF6B7280);
