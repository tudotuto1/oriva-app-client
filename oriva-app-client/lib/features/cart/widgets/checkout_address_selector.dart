import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../addresses/address_providers.dart';
import '../../addresses/address_models.dart';
import '../checkout_address_provider.dart';

class CheckoutAddressSelector extends ConsumerWidget {
  const CheckoutAddressSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAddresses = ref.watch(myAddressesProvider);
    final selectedId = ref.watch(selectedCheckoutAddressIdProvider);

    return asyncAddresses.when(
      loading: () => const _Skeleton(),
      error: (_, __) => _ErrorTile(onRetry: () {
        ref.invalidate(myAddressesProvider);
      }),
      data: (addresses) {
        // Pré-sélection : adresse par défaut OU première
        if (selectedId == null && addresses.isNotEmpty) {
          final defaultAddr = addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => addresses.first,
          );
          // Set après le frame courant pour éviter modif pendant build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(selectedCheckoutAddressIdProvider.notifier).state =
                defaultAddr.id;
          });
        }

        if (addresses.isEmpty) {
          return _NoAddressCard(onTap: () {
            context.push('/address/new');
          });
        }

        final selected = selectedId != null
            ? addresses.firstWhere(
                (a) => a.id == selectedId,
                orElse: () => addresses.first,
              )
            : addresses.first;

        return _AddressCard(
          address: selected,
          onTap: () {
            HapticFeedback.lightImpact();
            _showPicker(context, ref, addresses, selected.id);
          },
        );
      },
    );
  }

  void _showPicker(
    BuildContext context,
    WidgetRef ref,
    List<Address> addresses,
    String currentId,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Adresse de livraison',
                  style: TextStyle(
                    color: Color(0xFFF5F0E8),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...addresses.map((a) {
                final selected = a.id == currentId;
                return InkWell(
                  onTap: () {
                    ref
                        .read(selectedCheckoutAddressIdProvider.notifier)
                        .state = a.id;
                    Navigator.of(ctx).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? LucideIcons.circleCheck
                              : LucideIcons.circle,
                          color: selected
                              ? const Color(0xFFC9A96E)
                              : const Color(0xFF555555),
                          size: 22,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.label,
                                style: const TextStyle(
                                  color: Color(0xFFF5F0E8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${a.recipientName} • ${a.city}'
                                '${a.district != null && a.district!.isNotEmpty ? ", ${a.district}" : ""}',
                                style: const TextStyle(
                                  color: Color(0xFF888888),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const Divider(color: Color(0xFF1A1A1A)),
              ListTile(
                leading: const Icon(
                  LucideIcons.plus,
                  color: Color(0xFFC9A96E),
                ),
                title: const Text(
                  'Ajouter une adresse',
                  style: TextStyle(color: Color(0xFFF5F0E8)),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.push('/address/new');
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address, required this.onTap});
  final Address address;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1A1A1A)),
        ),
        child: Row(
          children: [
            const Icon(
              LucideIcons.mapPin,
              color: Color(0xFFC9A96E),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          address.label,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFF5F0E8),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC9A96E),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Par défaut',
                            style: TextStyle(
                              color: Color(0xFF080808),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${address.recipientName} • ${address.city}'
                    '${address.district != null && address.district!.isNotEmpty ? ", ${address.district}" : ""}',
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              color: Color(0xFF555555),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoAddressCard extends StatelessWidget {
  const _NoAddressCard({required this.onTap});
  final VoidCallback onTap;

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
            color: const Color(0xFFC9A96E),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              LucideIcons.mapPinPlus,
              color: Color(0xFFC9A96E),
              size: 22,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ajouter une adresse de livraison',
                    style: TextStyle(
                      color: Color(0xFFF5F0E8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Obligatoire pour valider la commande',
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              color: Color(0xFFC9A96E),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onRetry,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(LucideIcons.triangleAlert, color: Colors.redAccent),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Impossible de charger tes adresses. Tape pour réessayer.',
                style: TextStyle(color: Color(0xFFF5F0E8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
