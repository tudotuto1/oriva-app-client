import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  // Valeurs par défaut Oriva-DB (Canada Central).
  // La clé anon est PUBLIQUE par conception : elle vit dans le bundle client
  // et tout accès est protégé par les politiques RLS côté serveur.
  // Ce fallback garantit que l'app trouve toujours le bon projet Supabase
  // même si le fichier .env n'est pas chargé (cas release Android).
  static const String _fallbackUrl =
      'https://oclpkzmpaaurqkefbbij.supabase.co';
  static const String _fallbackAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9jbHBrem1wYWF1cnFrZWZiYmlqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY1MTM2MzksImV4cCI6MjA5MjA4OTYzOX0.tpxZUppz_yYNIBpYA9CCHhKSSjJI32XHBzpnzEN-jHg';

  static Future<void> init() async {
    final envUrl = dotenv.env['SUPABASE_URL'];
    final envKey = dotenv.env['SUPABASE_ANON_KEY'];

    final url = (envUrl != null && envUrl.isNotEmpty) ? envUrl : _fallbackUrl;
    final anonKey =
        (envKey != null && envKey.isNotEmpty) ? envKey : _fallbackAnonKey;

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
  static User? get currentUser => client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;
}
