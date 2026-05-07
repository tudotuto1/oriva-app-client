import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'address_models.dart';
import 'address_repository.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository(Supabase.instance.client);
});

final myAddressesProvider =
    FutureProvider.autoDispose<List<Address>>((ref) async {
  final repo = ref.read(addressRepositoryProvider);
  return repo.fetchMyAddresses();
});
