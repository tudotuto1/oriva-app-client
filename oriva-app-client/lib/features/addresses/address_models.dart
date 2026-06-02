import 'package:flutter/foundation.dart';

@immutable
class Address {
  final String id;
  final String label;
  final String recipientName;
  final String phone;
  final String countryCode;
  final String city;
  final String? district;
  final String? streetDetails;
  final String? landmark;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final DateTime createdAt;

  const Address({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.countryCode,
    required this.city,
    this.district,
    this.streetDetails,
    this.landmark,
    this.latitude,
    this.longitude,
    required this.isDefault,
    required this.createdAt,
  });

  factory Address.fromJson(Map<String, dynamic> j) {
    return Address(
      id: j['id'].toString(),
      label: j['label']?.toString() ?? '',
      recipientName: j['recipient_name']?.toString() ?? '',
      phone: j['phone']?.toString() ?? '',
      countryCode: j['country_code']?.toString() ?? 'BF',
      city: j['city']?.toString() ?? '',
      district: j['district']?.toString(),
      streetDetails: j['street_details']?.toString(),
      landmark: j['landmark']?.toString(),
      latitude: (j['latitude'] as num?)?.toDouble(),
      longitude: (j['longitude'] as num?)?.toDouble(),
      isDefault: j['is_default'] == true,
      createdAt: DateTime.tryParse(j['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  String get summary {
    final parts = <String>[
      city,
      if (district != null && district!.isNotEmpty) district!,
      if (streetDetails != null && streetDetails!.isNotEmpty) streetDetails!,
    ];
    return parts.join(' · ');
  }
}

class AddressException implements Exception {
  final String code;
  final String userMessage;
  AddressException(this.code, this.userMessage);
}
