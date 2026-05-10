import 'package:flutter_riverpod/flutter_riverpod.dart';

// L'address_id sélectionné pour le checkout courant.
// Reset à null après création de commande réussie.
final selectedCheckoutAddressIdProvider =
    StateProvider<String?>((_) => null);
