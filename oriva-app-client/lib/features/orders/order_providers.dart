import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cart/cart_provider.dart';
import '../cart/checkout_address_provider.dart';
import 'order_models.dart';
import 'order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

class CreateOrderController extends AsyncNotifier<CreateOrderResult?> {
  @override
  Future<CreateOrderResult?> build() async => null;

  Future<CreateOrderResult?> submit({required String addressId}) async {
    final repo = ref.read(orderRepositoryProvider);
    final cartItems = ref.read(cartProvider);

    state = const AsyncValue.loading();

    try {
      final result = await repo.createOrder(
        items: cartItems,
        addressId: addressId,
      );
      ref.read(cartProvider.notifier).clear();
      ref.read(selectedCheckoutAddressIdProvider.notifier).state = null;
      state = AsyncValue.data(result);
      return result;
    } on CreateOrderException catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final createOrderControllerProvider =
    AsyncNotifierProvider<CreateOrderController, CreateOrderResult?>(
  CreateOrderController.new,
);
