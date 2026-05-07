import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'order_history_models.dart';
import 'order_history_providers.dart';

class OrderHistoryPage extends ConsumerWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncOrders = ref.watch(orderHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080808),
        title: const Text(
          'Mes commandes',
          style: TextStyle(color: Color(0xFFF5F0E8)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFC9A96E)),
      ),
      body: asyncOrders.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFC9A96E)),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Impossible de charger les commandes.',
                style: TextStyle(color: Color(0xFFF5F0E8)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.refresh(orderHistoryProvider),
                child: const Text(
                  'Réessayer',
                  style: TextStyle(color: Color(0xFFC9A96E)),
                ),
              ),
            ],
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Text(
                'Aucune commande pour le moment.',
                style: TextStyle(color: Color(0xFF888888)),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _OrderCard(order: orders[i]),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final OrderHistoryItem order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.shortId,
                style: const TextStyle(
                  color: Color(0xFFC9A96E),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              _StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 12),
          _StepIndicator(status: order.status),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.itemCount} article${order.itemCount > 1 ? 's' : ''}',
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 13,
                ),
              ),
              Text(
                '${_formatFcfa(order.total.toInt())} FCFA',
                style: const TextStyle(
                  color: Color(0xFFF5F0E8),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(order.createdAt),
            style: const TextStyle(
              color: Color(0xFF555555),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} à '
        '${dt.hour.toString().padLeft(2, '0')}h'
        '${dt.minute.toString().padLeft(2, '0')}';
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final OrderStatus status;

  Color get _color {
    switch (status) {
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.shipped:
        return Colors.blue;
      case OrderStatus.pending:
        return const Color(0xFFC9A96E);
      case OrderStatus.cancelled:
        return Colors.redAccent;
      default:
        return const Color(0xFF555555);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.5)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.status});
  final OrderStatus status;

  static const _steps = ['Confirmée', 'Expédiée', 'Livrée'];

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.paymentPending ||
        status == OrderStatus.cancelled ||
        status == OrderStatus.unknown) {
      return const SizedBox.shrink();
    }
    final currentStep = (status.step - 1).clamp(0, 2);
    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              color: i ~/ 2 < currentStep
                  ? const Color(0xFFC9A96E)
                  : const Color(0xFF2A2A2A),
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final done = stepIndex <= currentStep;
        return Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? const Color(0xFFC9A96E)
                    : const Color(0xFF2A2A2A),
                border: Border.all(
                  color: done
                      ? const Color(0xFFC9A96E)
                      : const Color(0xFF444444),
                ),
              ),
              child: done
                  ? const Icon(Icons.check, size: 12, color: Color(0xFF080808))
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              _steps[stepIndex],
              style: TextStyle(
                fontSize: 9,
                color: done
                    ? const Color(0xFFC9A96E)
                    : const Color(0xFF555555),
              ),
            ),
          ],
        );
      }),
    );
  }
}
