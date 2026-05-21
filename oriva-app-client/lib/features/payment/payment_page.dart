import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/widgets/animated_success.dart';
import '../../core/widgets/oriva_error_state.dart';
import 'payment_models.dart';
import 'payment_providers.dart';
import 'widgets/phone_input.dart';

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key, required this.orderId, required this.totalFcfa});
  final String orderId;
  final int totalFcfa;

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  final _phoneCtrl = TextEditingController();
  String? _localError;
  bool _submitting = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^[567]\d{7}$').hasMatch(phone.trim());
  }

  Future<void> _onPay() async {
    if (_submitting) return;
    final phone = _phoneCtrl.text.trim();
    if (!_isValidPhone(phone)) {
      setState(() => _localError = 'Numéro invalide. 8 chiffres, début 5/6/7.');
      return;
    }
    setState(() {
      _localError = null;
      _submitting = true;
    });
    final controller =
        ref.read(paymentSessionProvider(widget.orderId).notifier);
    await controller.startPayment(phone);
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(paymentSessionProvider(widget.orderId));

    ref.listen<AsyncValue<PaymentSessionState>>(
      paymentSessionProvider(widget.orderId),
      (prev, next) {
        final s = next.value;
        if (s == null) return;
        if (s.status == PaymentStatus.success && mounted) {
          context.go('/order-confirmation/${widget.orderId}');
        }
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080808),
        title: const Text(
          'Paiement',
          style: TextStyle(color: Color(0xFFF5F0E8)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFC9A96E)),
      ),
      body: SafeArea(
        child: asyncState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFC9A96E)),
          ),
          error: (e, _) => _buildError(e.toString()),
          data: (s) => _buildBody(s),
        ),
      ),
    );
  }

  Widget _buildBody(PaymentSessionState s) {
    if (s.status == PaymentStatus.pending ||
        (s.status == PaymentStatus.initiated && s.paymentAttemptId != null)) {
      return _buildPending(s);
    }
    if (s.status.isTerminal && s.status != PaymentStatus.success) {
      return _buildResult(s);
    }
    return _buildForm();
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Montant à payer',
            style: TextStyle(color: Color(0xFFF5F0E8), fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatFcfa(widget.totalFcfa)} FCFA',
            style: const TextStyle(
              color: Color(0xFFC9A96E),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Numéro Orange Money / Moov',
            style: TextStyle(color: Color(0xFFF5F0E8), fontSize: 14),
          ),
          const SizedBox(height: 12),
          PhoneInputBF(
            controller: _phoneCtrl,
            enabled: !_submitting,
            errorText: _localError,
          ),
          const SizedBox(height: 8),
          const Text(
            'Préfixes valides : 70-79 (Orange), 50-66 (Moov)',
            style: TextStyle(color: Color(0xFF888888), fontSize: 12),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _submitting ? null : _onPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9A96E),
                disabledBackgroundColor: const Color(0xFF555555),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF080808),
                      ),
                    )
                  : Text(
                      'Payer ${_formatFcfa(widget.totalFcfa)} FCFA',
                      style: const TextStyle(
                        color: Color(0xFF080808),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPending(PaymentSessionState s) {
    final remaining = (45 - s.elapsedSeconds).clamp(0, 45);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFFC9A96E)),
          const SizedBox(height: 32),
          Text(
            s.provider?.label ?? 'Validation en cours',
            style: const TextStyle(
              color: Color(0xFFC9A96E),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Validez la transaction sur votre téléphone.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFF5F0E8), fontSize: 14),
          ),
          const SizedBox(height: 24),
          Text(
            'Délai restant : ${remaining}s',
            style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () {
              ref
                  .read(paymentSessionProvider(widget.orderId).notifier)
                  .cancel();
            },
            child: const Text(
              'Annuler',
              style: TextStyle(color: Color(0xFF888888)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(PaymentSessionState s) {
    final isSuccess = s.status == PaymentStatus.success;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isSuccess
              ? const AnimatedSuccessCheck(size: 64)
              : const Icon(
                  LucideIcons.circleX,
                  color: Colors.redAccent,
                  size: 64,
                ),
          const SizedBox(height: 24),
          Text(
            _statusLabel(s.status),
            style: TextStyle(
              color: isSuccess
                  ? const Color(0xFFC9A96E)
                  : const Color(0xFFF5F0E8),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            s.errorMessage ?? 'Veuillez réessayer.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFF5F0E8), fontSize: 14),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                ref
                    .read(paymentSessionProvider(widget.orderId).notifier)
                    .reset();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9A96E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Réessayer',
                style: TextStyle(
                  color: Color(0xFF080808),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text(
              'Retour à l\'accueil',
              style: TextStyle(color: Color(0xFF888888)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String msg) {
    return OrivaErrorState(
      message: 'Une erreur de paiement est survenue.',
      hint: 'Réessayez ou contactez le support si le problème persiste.',
      onRetry: () {
        ref
            .read(paymentSessionProvider(widget.orderId).notifier)
            .reset();
      },
    );
  }

  String _statusLabel(PaymentStatus s) {
    switch (s) {
      case PaymentStatus.success:
        return 'Paiement réussi';
      case PaymentStatus.failed:
        return 'Paiement échoué';
      case PaymentStatus.timeout:
        return 'Délai dépassé';
      case PaymentStatus.cancelled:
        return 'Paiement annulé';
      default:
        return 'État inconnu';
    }
  }

  String _formatFcfa(int amount) {
    final str = amount.toString();
    final buf = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(' ');
      buf.write(str[i]);
    }
    return buf.toString();
  }
}
