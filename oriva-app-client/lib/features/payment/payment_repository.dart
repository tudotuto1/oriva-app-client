import 'package:supabase_flutter/supabase_flutter.dart';
import 'payment_models.dart';

class PaymentRepository {
  PaymentRepository(this._client);
  final SupabaseClient _client;

  // SÉCURITÉ : aucun buyer_id envoyé. Edge Function lit auth.uid().
  Future<InitiatePaymentResult> initiatePayment({
    required String orderId,
    required String phoneLocal8Digits,
  }) async {
    _validatePhone(phoneLocal8Digits);

    final session = _client.auth.currentSession;
    if (session == null) {
      throw PaymentException('NOT_AUTHENTICATED', 'Connectez-vous pour payer.');
    }

    try {
      final response = await _client.functions.invoke(
        'initiate_payment',
        body: {
          'order_id': orderId,
          'phone_number': phoneLocal8Digits,
          'country_code': 'BF',
        },
      );

      final data = response.data;
      if (data is! Map) {
        throw PaymentException('INVALID_RESPONSE', 'Réponse serveur invalide.');
      }

      if (data['error'] != null) {
        throw _mapError(data['error']?.toString() ?? 'UNKNOWN');
      }

      return InitiatePaymentResult(
        paymentAttemptId: data['payment_attempt_id']?.toString() ?? '',
        provider: PaymentProvider.fromString(data['provider']?.toString()),
        status: PaymentStatus.fromString(data['status']?.toString()),
      );
    } on FunctionException catch (e) {
      throw _mapError(e.details?.toString() ?? 'NETWORK_ERROR');
    }
  }

  Future<PaymentStatusResult> checkStatus({
    required String paymentAttemptId,
  }) async {
    final session = _client.auth.currentSession;
    if (session == null) {
      throw PaymentException('NOT_AUTHENTICATED', 'Session expirée.');
    }

    try {
      final response = await _client.functions.invoke(
        'check_payment_status',
        body: {'payment_attempt_id': paymentAttemptId},
      );

      final data = response.data;
      if (data is! Map) {
        return const PaymentStatusResult(status: PaymentStatus.unknown);
      }

      return PaymentStatusResult(
        status: PaymentStatus.fromString(data['status']?.toString()),
        errorCode: data['error_code']?.toString(),
        errorMessage: data['error_message']?.toString(),
      );
    } on FunctionException catch (_) {
      return const PaymentStatusResult(status: PaymentStatus.unknown);
    }
  }

  void _validatePhone(String phone) {
    final clean = phone.trim();
    final regex = RegExp(r'^[567]\d{7}$');
    if (!regex.hasMatch(clean)) {
      throw PaymentException(
        'INVALID_PHONE',
        'Numéro invalide. 8 chiffres, début 5, 6 ou 7.',
      );
    }
  }

  PaymentException _mapError(String code) {
    switch (code) {
      case 'NOT_AUTHENTICATED':
        return PaymentException(code, 'Connectez-vous pour payer.');
      case 'NOT_YOUR_ORDER':
        return PaymentException(code, 'Cette commande ne vous appartient pas.');
      case 'ORDER_NOT_FOUND':
        return PaymentException(code, 'Commande introuvable.');
      case 'ORDER_NOT_PAYABLE':
        return PaymentException(code, 'Cette commande ne peut plus être payée.');
      case 'INVALID_PHONE':
        return PaymentException(code, 'Numéro invalide. 8 chiffres, début 5/6/7.');
      case 'UNSUPPORTED_PROVIDER':
        return PaymentException(code, 'Opérateur non supporté.');
      case 'PAYMENT_EXPIRED':
        return PaymentException(code, 'Délai de paiement dépassé. Recommencez.');
      case 'RATE_LIMITED':
        return PaymentException(code, 'Trop de tentatives. Patientez.');
      default:
        return PaymentException(code, 'Erreur paiement. Réessayez.');
    }
  }
}
