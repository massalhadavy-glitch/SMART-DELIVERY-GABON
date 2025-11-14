/// FICHIER EXEMPLE - COPIEZ CE FICHIER EN supabase_config.dart
/// et remplacez les valeurs par vos credentials Supabase
/// 
/// Pour obtenir vos credentials :
/// 1. Allez sur https://supabase.com
/// 2. Créez un nouveau projet
/// 3. Dans Settings > API, copiez :
///    - Project URL
///    - anon public key

class SupabaseConfig {
  /// URL de votre projet Supabase
  /// Exemple: https://abcdefghijklmnop.supabase.co
  static const String supabaseUrl = 'VOTRE_URL_SUPABASE';

  /// Clé publique anonyme de votre projet
  /// Commence par: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
  static const String supabaseAnonKey = 'VOTRE_CLE_ANON';

  /// Active le mode debug (à désactiver en production)
  static const bool debugMode = true;
}

