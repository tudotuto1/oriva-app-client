import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'address_models.dart';
import 'address_providers.dart';
import 'map_picker_page.dart';

class AddressFormPage extends ConsumerStatefulWidget {
  const AddressFormPage({super.key, this.addressId});
  final String? addressId;

  @override
  ConsumerState<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends ConsumerState<AddressFormPage> {
  final _label = TextEditingController();
  final _recipient = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _district = TextEditingController();
  final _street = TextEditingController();
  final _landmark = TextEditingController();
  bool _isDefault = false;
  bool _saving = false;
  bool _loading = true;
  String? _error;
  double? _latitude;
  double? _longitude;

  bool get _isEdit => widget.addressId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _loadExisting();
    } else {
      _loading = false;
    }
  }

  Future<void> _loadExisting() async {
    try {
      final list =
          await ref.read(addressRepositoryProvider).fetchMyAddresses();
      final addr = list.firstWhere(
        (a) => a.id == widget.addressId,
        orElse: () => throw AddressException(
          'NOT_FOUND',
          'Adresse introuvable.',
        ),
      );
      if (!mounted) return;
      _label.text = addr.label;
      _recipient.text = addr.recipientName;
      _phone.text = addr.phone;
      _city.text = addr.city;
      _district.text = addr.district ?? '';
      _street.text = addr.streetDetails ?? '';
      _landmark.text = addr.landmark ?? '';
      _isDefault = addr.isDefault;
      _latitude = addr.latitude;
      _longitude = addr.longitude;
      setState(() => _loading = false);
    } on AddressException catch (e) {
      if (mounted) setState(() {
        _error = e.userMessage;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() {
        _error = 'Erreur chargement.';
        _loading = false;
      });
    }
  }

  Future<void> _pickOnMap() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => MapPickerPage(
          initialLat: _latitude,
          initialLng: _longitude,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repo = ref.read(addressRepositoryProvider);
      if (_isEdit) {
        await repo.updateAddress(
          id: widget.addressId!,
          label: _label.text,
          recipientName: _recipient.text,
          phoneLocal8Digits: _phone.text,
          city: _city.text,
          district: _district.text,
          streetDetails: _street.text,
          landmark: _landmark.text,
          latitude: _latitude,
          longitude: _longitude,
        );
        if (_isDefault) await repo.setDefault(widget.addressId!);
      } else {
        await repo.createAddress(
          label: _label.text,
          recipientName: _recipient.text,
          phoneLocal8Digits: _phone.text,
          city: _city.text,
          district: _district.text,
          streetDetails: _street.text,
          landmark: _landmark.text,
          isDefault: _isDefault,
          latitude: _latitude,
          longitude: _longitude,
        );
      }
      ref.invalidate(myAddressesProvider);
      if (mounted) context.pop();
    } on AddressException catch (e) {
      if (mounted) setState(() => _error = e.userMessage);
    } catch (e) {
      if (mounted) setState(() => _error = 'Erreur enregistrement.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _label.dispose();
    _recipient.dispose();
    _phone.dispose();
    _city.dispose();
    _district.dispose();
    _street.dispose();
    _landmark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080808),
        title: Text(
          _isEdit ? 'Modifier adresse' : 'Nouvelle adresse',
          style: const TextStyle(color: Color(0xFFF5F0E8)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFC9A96E)),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFC9A96E)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC9A96E).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFC9A96E)),
                    ),
                    child: const Text(
                      '📍 Carte activée — bouton « Ajouter » tout en bas',
                      style: TextStyle(color: Color(0xFFC9A96E), fontSize: 13),
                    ),
                  ),
                  _field('Type d\'adresse *', _label, hint: 'Ex : Maison, Bureau, Boutique...'),
                  _field('Nom du destinataire *', _recipient,
                      hint: 'Bachir Bondo'),
                  _phoneField(),
                  _field('Ville *', _city, hint: 'Ouagadougou'),
                  _field('Quartier', _district, hint: 'Ouaga 2000'),
                  _field('Rue / précisions', _street,
                      hint: 'Rue 123, secteur 15'),
                  _field('Repère', _landmark,
                      hint: 'À côté de la pharmacie...'),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _pickOnMap,
                      icon: const Icon(Icons.map_outlined,
                          color: Color(0xFFC9A96E)),
                      label: Text(
                        (_latitude != null && _longitude != null)
                            ? 'Position enregistrée ✓ (modifier)'
                            : 'Choisir la position sur la carte',
                        style: const TextStyle(color: Color(0xFFF5F0E8)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFC9A96E)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Switch(
                        value: _isDefault,
                        activeColor: const Color(0xFFC9A96E),
                        onChanged: (v) => setState(() => _isDefault = v),
                      ),
                      const Text(
                        'Définir par défaut',
                        style: TextStyle(color: Color(0xFFF5F0E8)),
                      ),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
      bottomNavigationBar: _loading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9A96E),
                      disabledBackgroundColor: const Color(0xFF555555),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF080808),
                            ),
                          )
                        : Text(
                            _isEdit ? 'Enregistrer' : 'Ajouter',
                            style: const TextStyle(
                              color: Color(0xFF080808),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _field(String label, TextEditingController c, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFFF5F0E8), fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            style: const TextStyle(color: Color(0xFFF5F0E8)),
            decoration: _decoration(hint),
          ),
        ],
      ),
    );
  }

  Widget _phoneField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Téléphone *',
              style: TextStyle(color: Color(0xFFF5F0E8), fontSize: 13)),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFC9A96E)),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '🇧🇫 +226',
                  style: TextStyle(
                    color: Color(0xFFF5F0E8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _phone,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  style: const TextStyle(color: Color(0xFFF5F0E8)),
                  decoration: _decoration('7X XX XX XX'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          TextStyle(color: const Color(0xFFF5F0E8).withOpacity(0.3)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFC9A96E)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            const BorderSide(color: Color(0xFFC9A96E), width: 2),
      ),
    );
  }
}
