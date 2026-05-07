import 'package:flutter/foundation.dart';

enum PaymentStatus {
  initiated,
  pending,
  success,
  failed,
  timeout,
  cancelled,
  unknown;

  static PaymentStatus fromString(String? raw) {
    switch (raw) {
      case 'initiated':
        return PaymentStatus.initiated;
      case 'pending':
        return PaymentStatus.pending;
      case 'success':
        return PaymentStatus.success;
      case 'failed':
        return PaymentStatus.failed;
      case 'timeout':
        return PaymentStatus.timeout;
      case 'cancelled':
        return PaymentStatus.cancelled;
      default:
        return PaymentStatus.unknown;
    }
  }

  bool get isTerminal =>
      this == PaymentStatus.success ||
      this == PaymentStatus.failed ||
      this == PaymentStatus.timeout ||
      this == PaymentStatus.cancelled;
}

enum PaymentProvider {
  ligdicashOrangeBf,
  ligdicashMoovBf,
  mock,
  unknown;

  String get label {
    switch (this) {
      case PaymentProvider.ligdicashOrangeBf:
        return 'Orange Money';
      case PaymentProvider.ligdicashMoovBf:
        return 'Moov Money';
      case PaymentProvider.mock:
        return 'Mode test';
      case PaymentProvider.unknown:
        return 'Inconnu';
    }
  }

  static PaymentProvider fromString(String? raw) {
    switch (raw) {
      case 'ligdicash_orange_bf':
        return PaymentProvider.ligdicashOrangeBf;
      case 'ligdicash_moov_bf':
        return PaymentProvider.ligdicashMoovBf;
      case 'mock':
        return PaymentProvider.mock;
      default:
        return PaymentProvider.unknown;
    }
  }
}

@immutable
class InitiatePaymentResult {
  final String paymentAttemptId;
  final PaymentProvider provider;
  final PaymentStatus status;

  const InitiatePaymentResult({
    required this.paymentAttemptId,
    required this.provider,
    required this.status,
  });
}

@immutable
class PaymentStatusResult {
  final PaymentStatus status;
  final String? errorCode;
  final String? errorMessage;

  const PaymentStatusResult({
    required this.status,
    this.errorCode,
    this.errorMessage,
  });
}

class PaymentException implements Exception {
  final String code;
  final String userMessage;
  PaymentException(this.code, this.userMessage);
  @override
  String toString() => 'PaymentException($code): $userMessage';
}
