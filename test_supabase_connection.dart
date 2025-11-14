import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/config/supabase_config.dart';

void main() async {
  print('🔌 Test de connexion Supabase...\n');
  
  try {
    // Initialiser Supabase
    print('📝 Initialisation de Supabase...');
    print('URL: ${SupabaseConfig.supabaseUrl}');
    print('Key: ${SupabaseConfig.supabaseAnonKey.substring(0, 20)}...\n');
    
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
      debug: SupabaseConfig.debugMode,
    );
    
    print('✅ Supabase initialisé avec succès!\n');
    
    // Test de connexion à la base de données
    print('🧪 Test de connexion à la base de données...');
    final supabase = Supabase.instance.client;
    
    try {
      // Essayer de lire de la table packages
      final response = await supabase.from('packages').select().limit(1);
      print('✅ Connexion à la base de données réussie!');
      print('📦 Table packages accessible');
      print('📊 Nombre de colis: ${response.length}\n');
    } catch (e) {
      print('⚠️  Table packages non trouvée ou inaccessible');
      print('    Erreur: $e');
      print('\n💡 Créez la table packages dans Supabase (voir CONFIGURATION_SUPABASE.md)\n');
    }
    
    // Test de connexion à la table admins
    try {
      final response = await supabase.from('admins').select().limit(1);
      print('✅ Table admins accessible');
      print('👥 Nombre d\'admins: ${response.length}\n');
    } catch (e) {
      print('⚠️  Table admins non trouvée ou inaccessible');
      print('    Erreur: $e');
      print('\n💡 Créez la table admins dans Supabase (voir CONFIGURATION_SUPABASE.md)\n');
    }
    
    print('🎉 Tous les tests sont terminés!');
    print('\n✅ La connexion Supabase fonctionne correctement.');
    print('⚠️  Vérifiez que les tables sont créées (voir CONFIGURATION_SUPABASE.md)\n');
    
  } catch (e) {
    print('❌ ERREUR lors de la connexion Supabase:');
    print('   $e\n');
    print('🔍 Vérifiez:');
    print('   1. Vos credentials dans lib/config/supabase_config.dart');
    print('   2. Que votre projet Supabase existe');
    print('   3. Que vous êtes connecté à Internet\n');
    exit(1);
  }
  
  exit(0);
}

