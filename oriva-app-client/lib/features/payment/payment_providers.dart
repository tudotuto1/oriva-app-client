import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'payment_models.dart';
import 'payment_repository.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(Supabase.instance.client);
});

class PaymentSessionState {
  final PaymentStatus status;
  final String? paymentAttemptId;
  final PaymentProvider? provider;
  final String? errorCode;
  final String? errorMessage;
  final int elapsedSeconds;

  const PaymentSessionState({
    this.status = PaymentStatus.initiated,
    this.paymentAttemptId,
    this.provider,
    this.errorCode,
    this.errorMessage,
    this.elapsedSeconds = 0,
  });

  PaymentSessionState copyWith({
    PaymentStatus? status,
    String? paymentAttemptId,
    PaymentProvider? provider,
    String? errorCode,
    String? errorMessage,
    int? elapsedSeconds,
  }) {
    return PaymentSessionState(
      status: status ?? this.status,
      paymentAttemptId: paymentAttemptId ?? this.paymentAttemptId,
      provider: provider ?? this.provider,
      errorCode: errorCode,
      errorMessage: errorMessage,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}

class PaymentSessionController extends AutoDisposeFamilyAsyncNotifier<
    PaymentSessionState, String> {
  Timer? _pollTimer;
  Timer? _elapsedTimer;
  static const _maxPollSeconds = 45;
  static const _pollIntervalSeconds = 2;

  @override
  Future<PaymentSessionState> build(String orderId) async {
    ref.onDispose(_cleanup);
    return const PaymentSessionState();
  }

  Future<void> startPayment(String phoneLocal8Digits) async {
    final orderId = arg;
    state = const AsyncLoading();

    try {
      final repo = ref.read(paymentRepositoryProvider);
      final result = await repo.initiatePayment(
        orderId: orderId,
        phoneLocal8Digits: phoneLocal8Digits,
      );

      state = AsyncData(PaymentSessionState(
        status: result.status,
        paymentAttemptId: result.paymentAttemptId,
        provider: result.provider,
      ));

      if (!result.status.isTerminal) {
        _startPolling(result.paymentAttemptId);
      }
    } on PaymentException catch (e) {
      state = AsyncData(PaymentSessionState(
        status: PaymentStatus.failed,
        errorCode: e.code,
        errorMessage: e.userMessage,
      ));
    } catch (_) {
      state = AsyncData(const PaymentSessionState(
        status: PaymentStatus.failed,
        errorCode: 'UNEXPECTED',
        errorMessage: 'Erreur inattendue. Réessayez.',
      ));
    }
  }

  void _startPolling(String attemptId) {
    _cleanup();
    var elapsed = 0;

    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsed++;
      final current = state.value;
      if (current != null) {
        state = AsyncData(current.copyWith(elapsedSeconds: elapsed));
      }
    });

    _pollTimer = Timer.periodic(
      const Duration(seconds: _pollIntervalSeconds),
      (timer) async {
        if (elapsed >= _maxPollSeconds) {
          _cleanup();
          final current = state.value;
          state = AsyncData((current ?? const PaymentSessionState()).copyWith(
            status: PaymentStatus.timeout,
            errorCode: 'CLIENT_TIMEOUT',
            errorMessage: 'Délai dépassé. Vérifiez votre commande.',
          ));
          return;
        }

        try {
          final repo = ref.read(paymentRepositoryProvider);
          final result = await repo.checkStatus(paymentAttemptId: attemptId);

          if (result.status.isTerminal) {
            _cleanup();
            final current = state.value;
            state = AsyncData((current ?? const PaymentSessionState()).copyWith(
              status: result.status,
              errorCode: result.errorCode,
              errorMessage: result.errorMessage,
            ));
          }
        } catch (_) {
          // SÉCURITÉ : ignorer erreur réseau ponctuelle, retry au prochain tick
        }
      },
    );
  }

  void cancel() {
    _cleanup();
    final current = state.value;
    state = AsyncData((current ?? const PaymentSessionState()).copyWith(
      status: PaymentStatus.cancelled,
      errorCode: 'USER_CANCELLED',
      errorMessage: 'Paiement annulé.',
    ));
  }

  void reset() {
    _cleanup();
    state = const AsyncData(PaymentSessionState());
  }

  void _cleanup() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
  }
}

final paymentSessionProvider = AutoDisposeAsyncNotifierProviderFamily<
    PaymentSessionController, PaymentSessionState, String>(
  PaymentSessionController.new,
);
