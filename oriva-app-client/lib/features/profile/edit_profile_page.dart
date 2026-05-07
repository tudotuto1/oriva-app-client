import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _editProfileLoadingProvider = StateProvider<bool>((ref) => false);

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _displayNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _errorMsg;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('display_name, phone')
          .eq('id', user.id)
          .maybeSingle();
      if (mounted && data != null) {
        _displayNameCtrl.text = data['display_name']?.toString() ?? '';
        _phoneCtrl.text = data['phone']?.toString() ?? '';
        setState(() => _loaded = true);
      } else if (mounted) {
        setState(() => _loaded = true);
      }
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  Future<void> _save() async {
    final name = _displayNameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMsg = 'Nom requis.');
      return;
    }
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    ref.read(_editProfileLoadingProvider.notifier).state = true;
    setState(() => _errorMsg = null);

    try {
      await Supabase.instance.client.from('profiles').update({
        'display_name': name,
        'phone': _phoneCtrl.text.trim().isEmpty
            ? null
            : _phoneCtrl.text.trim(),
      }).eq('id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour.'),
            backgroundColor: Color(0xFFC9A96E),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMsg = 'Erreur lors de la mise à jour.');
      }
    } finally {
      if (mounted) {
        ref.read(_editProfileLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(_editProfileLoadingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080808),
        title: const Text(
          'Modifier le profil',
          style: TextStyle(color: Color(0xFFF5F0E8)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFC9A96E)),
      ),
      body: !_loaded
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFC9A96E)),
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nom affiché',
                    style: TextStyle(
                      color: Color(0xFFF5F0E8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _displayNameCtrl,
                    style: const TextStyle(color: Color(0xFFF5F0E8)),
                    decoration: _inputDecoration('Ex: Bachir Bondo'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Téléphone (optionnel)',
                    style: TextStyle(
                      color: Color(0xFFF5F0E8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Color(0xFFF5F0E8)),
                    decoration: _inputDecoration('Ex: 70123456'),
                  ),
                  if (_errorMsg != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMsg!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: loading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC9A96E),
                        disabledBackgroundColor: const Color(0xFF555555),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF080808),
                              ),
                            )
                          : const Text(
                              'Enregistrer',
                              style: TextStyle(
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
            ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: const Color(0xFFF5F0E8).withOpacity(0.3),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFC9A96E)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFC9A96E), width: 2),
      ),
    );
  }
}
