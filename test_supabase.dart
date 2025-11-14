import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/config/supabase_config.dart';

/// Test de connexion Supabase
/// 
/// Exécution: dart run test_supabase.dart

void main() async {
  print('🔧 Test de connexion Supabase...\n');
  print('📋 Configuration:');
  print('   URL: ${SupabaseConfig.supabaseUrl}');
  print('   Key: ${SupabaseConfig.supabaseAnonKey.substring(0, 30)}...\n');
  
  try {
    print('⏳ Initialisation de Supabase...');
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
      debug: true,
    );
    
    print('✅ Supabase initialisé avec succès!\n');
    
    final client = Supabase.instance.client;
    print('🔗 Client Supabase connecté\n');
    
    // Test table packages
    print('📦 Test de lecture de la table "packages"...');
    try {
      final response = await client.from('packages').select().limit(1);
      print('✅ Table packages accessible (${response.length} résultat(s))\n');
    } catch (e) {
      print('⚠️  Erreur: $e');
      print('💡 La table packages n\'existe peut-être pas encore\n');
    }
    
    // Test table admins
    print('👑 Test de lecture de la table "admins"...');
    try {
      final response = await client.from('admins').select().limit(1);
      print('✅ Table admins accessible (${response.length} résultat(s))\n');
    } catch (e) {
      print('⚠️  Erreur: $e');
      print('💡 La table admins n\'existe peut-être pas encore\n');
    }
    
    print('🎉 Connexion Supabase fonctionne correctement!');
    print('\n📝 Prochaines étapes:');
    print('   1. Créez les tables dans Supabase Dashboard');
    print('   2. Configurez les politiques RLS');
    print('   3. Lancez l\'application complète\n');
    
  } catch (e, stack) {
    print('❌ ERREUR lors de la connexion!');
    print('\n❌ $e\n');
    
    if (e.toString().contains('connection')) {
      print('💡 Vérifiez votre connexion internet\n');
    }
    if (e.toString().contains('Invalid API key')) {
      print('💡 Vérifiez votre clé API dans lib/config/supabase_config.dart\n');
    }
    if (e.toString().contains('not found')) {
      print('💡 Vérifiez votre URL Supabase dans lib/config/supabase_config.dart\n');
    }
    
    print('Stack trace:');
    print(stack);
  }
  
  print('🏁 Test terminé');
}

