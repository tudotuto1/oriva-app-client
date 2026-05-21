import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/oriva_error_state.dart';
import 'address_models.dart';
import 'address_providers.dart';
import '../orders/widgets/order_list_skeleton.dart';

class AddressesPage extends ConsumerWidget {
  const AddressesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAddrs = ref.watch(myAddressesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080808),
        title: const Text(
          'Mes adresses',
          style: TextStyle(color: Color(0xFFF5F0E8)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFC9A96E)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFC9A96E),
        onPressed: () => context.push('/address/new'),
        child: const Icon(Icons.add, color: Color(0xFF080808)),
      ),
      body: asyncAddrs.when(
        loading: () => const OrderListSkeleton(itemCount: 3),
        error: (e, _) => OrivaErrorState(
          message: 'Impossible de charger vos adresses.',
          onRetry: () {
            ref.invalidate(myAddressesProvider);
          },
        ),
        data: (list) {
          if (list.isEmpty) {
            return RefreshIndicator(
              color: const Color(0xFFC9A96E),
              backgroundColor: const Color(0xFF111111),
              onRefresh: () async {
                ref.invalidate(myAddressesProvider);
                await ref.read(myAddressesProvider.future);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Aucune adresse enregistrée.\nAjoutez-en une pour commander.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF888888), fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: const Color(0xFFC9A96E),
            backgroundColor: const Color(0xFF111111),
            onRefresh: () async {
              ref.invalidate(myAddressesProvider);
              await ref.read(myAddressesProvider.future);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _AddressCard(
              address: list[i],
              onTap: () => context.push('/address/edit/${list[i].id}'),
              onSetDefault: () async {
                HapticFeedback.lightImpact();
                try {
                  await ref
                      .read(addressRepositoryProvider)
                      .setDefault(list[i].id);
                  ref.invalidate(myAddressesProvider);
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Échec définition adresse par défaut.'),
                      ),
                    );
                  }
                }
              },
              onDelete: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: const Color(0xFF111111),
                    title: const Text(
                      'Supprimer cette adresse ?',
                      style: TextStyle(color: Color(0xFFF5F0E8)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Annuler',
                            style: TextStyle(color: Color(0xFF888888))),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Supprimer',
                            style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  HapticFeedback.mediumImpact();
                  try {
                    await ref
                        .read(addressRepositoryProvider)
                        .deleteAddress(list[i].id);
                    ref.invalidate(myAddressesProvider);
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Échec suppression.')),
                      );
                    }
                  }
                }
              },
            ),
          ),
          );
        },
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onTap,
    required this.onSetDefault,
    required this.onDelete,
  });

  final Address address;
  final VoidCallback onTap;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: address.isDefault
                ? const Color(0xFFC9A96E)
                : const Color(0xFF2A2A2A),
            width: address.isDefault ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    address.label,
                    style: const TextStyle(
                      color: Color(0xFFC9A96E),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC9A96E).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Par défaut',
                      style: TextStyle(
                        color: Color(0xFFC9A96E),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              address.recipientName,
              style: const TextStyle(
                color: Color(0xFFF5F0E8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '+226 ${address.phone}',
              style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              address.summary,
              style: const TextStyle(
                color: Color(0xFFF5F0E8),
                fontSize: 13,
              ),
            ),
            if (address.landmark != null && address.landmark!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Repère : ${address.landmark}',
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (!address.isDefault)
                  TextButton.icon(
                    onPressed: onSetDefault,
                    icon: const Icon(Icons.star_border,
                        size: 16, color: Color(0xFFC9A96E)),
                    label: const Text(
                      'Par défaut',
                      style: TextStyle(color: Color(0xFFC9A96E), fontSize: 12),
                    ),
                  ),
                const Spacer(),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
