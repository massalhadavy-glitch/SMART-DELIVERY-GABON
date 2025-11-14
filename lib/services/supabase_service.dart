import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseService {
  // Exemple : créer un utilisateur
  Future<AuthResponse> signUp(String email, String password) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Exemple : connexion utilisateur
  Future<AuthResponse> signIn(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Exemple : récupérer tous les colis
  Future<List<Map<String, dynamic>>> getPackages() async {
    final response = await supabase.from('packages').select();
    return response;
  }
}
