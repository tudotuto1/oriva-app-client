import 'package:supabase_flutter/supabase_flutter.dart';
import 'address_models.dart';

class AddressRepository {
  AddressRepository(this._client);
  final SupabaseClient _client;

  Future<List<Address>> fetchMyAddresses() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw AddressException('NOT_AUTHENTICATED', 'Connectez-vous.');
    }
    final response = await _client
        .from('addresses')
        .select()
        .eq('user_id', user.id)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);
    return (response as List)
        .map((e) => Address.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Address> createAddress({
    required String label,
    required String recipientName,
    required String phoneLocal8Digits,
    required String city,
    String? district,
    String? streetDetails,
    String? landmark,
    bool isDefault = false,
  }) async {
    _validatePhone(phoneLocal8Digits);
    if (label.trim().isEmpty) {
      throw AddressException('INVALID_LABEL', 'Libellé requis.');
    }
    if (recipientName.trim().isEmpty) {
      throw AddressException('INVALID_RECIPIENT', 'Nom du destinataire requis.');
    }
    if (city.trim().isEmpty) {
      throw AddressException('INVALID_CITY', 'Ville requise.');
    }

    final user = _client.auth.currentUser;
    if (user == null) {
      throw AddressException('NOT_AUTHENTICATED', 'Connectez-vous.');
    }

    final response = await _client
        .from('addresses')
        .insert({
          'user_id': user.id,
          'label': label.trim(),
          'recipient_name': recipientName.trim(),
          'phone': phoneLocal8Digits.trim(),
          'country_code': 'BF',
          'city': city.trim(),
          'district': district?.trim(),
          'street_details': streetDetails?.trim(),
          'landmark': landmark?.trim(),
          'is_default': isDefault,
        })
        .select()
        .single();

    final addr = Address.fromJson(response);

    if (isDefault) {
      await setDefault(addr.id);
    }
    return addr;
  }

  Future<Address> updateAddress({
    required String id,
    required String label,
    required String recipientName,
    required String phoneLocal8Digits,
    required String city,
    String? district,
    String? streetDetails,
    String? landmark,
  }) async {
    _validatePhone(phoneLocal8Digits);

    final response = await _client
        .from('addresses')
        .update({
          'label': label.trim(),
          'recipient_name': recipientName.trim(),
          'phone': phoneLocal8Digits.trim(),
          'city': city.trim(),
          'district': district?.trim(),
          'street_details': streetDetails?.trim(),
          'landmark': landmark?.trim(),
        })
        .eq('id', id)
        .select()
        .single();
    return Address.fromJson(response);
  }

  Future<void> deleteAddress(String id) async {
    await _client.from('addresses').delete().eq('id', id);
  }

  Future<void> setDefault(String addressId) async {
    await _client.rpc('set_default_address', params: {
      'p_address_id': addressId,
    });
  }

  void _validatePhone(String phone) {
    if (!RegExp(r'^[567]\d{7}$').hasMatch(phone.trim())) {
      throw AddressException(
        'INVALID_PHONE',
        'Numéro invalide. 8 chiffres, début 5/6/7.',
      );
    }
  }
}
