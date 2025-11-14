import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Convertit les formats gabonais en format international +241XXXXXXXX
String normalizePhoneNumber(String phone) {
  if (phone.isEmpty) return '';

  String numericPhone = phone.replaceAll(RegExp(r'\D'), '');

  if (numericPhone.startsWith('241') && numericPhone.length == 11) {
    return '+$numericPhone';
  }

  if (numericPhone.length == 8) {
    return '+241$numericPhone';
  }

  if (numericPhone.startsWith('0') && numericPhone.length == 9) {
    numericPhone = numericPhone.substring(1);
    if (numericPhone.length == 8) {
      return '+241$numericPhone';
    }
  }

  return numericPhone;
}

class AuthNotifier extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? _user; // email ou téléphone
  String? _role; // 'user' ou 'admin'

  String? get user => _user;
  String? get role => _role;
  bool get isAdmin => _role == 'admin';
  bool get isAuthenticated => _user != null;

  // ------------------------------------------------------------------
  // 🔐 Connexion utilisateur par téléphone (simulation)
  // ------------------------------------------------------------------
  Future<void> loginWithPhone(String phone) async {
    final normalized = normalizePhoneNumber(phone);
    await Future.delayed(const Duration(milliseconds: 500));

    if (normalized.startsWith('+241') && normalized.length == 12) {
      _user = normalized;
      _role = 'client';
      notifyListeners();
      debugPrint('✅ Utilisateur connecté: $_user');
    } else {
      throw Exception('Numéro invalide. Utilisez le format +241XXXXXXXX');
    }
  }

  // ------------------------------------------------------------------
  // 👑 Connexion admin par email & mot de passe via Supabase
  // ------------------------------------------------------------------
  Future<AuthResponse> loginWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Aucun utilisateur trouvé.');
      }

      _user = email;

      debugPrint('🔍 Vérification du rôle dans la table users pour userId: ${response.user!.id}');
      
      // Vérifie dans la table 'users' le rôle de l'utilisateur
      try {
        final userData = await _supabase
            .from('users')
            .select('role')
            .eq('id', response.user!.id)
            .maybeSingle();

        debugPrint('📊 Réponse de la requête users: $userData');

        if (userData != null && userData['role'] == 'admin') {
          // L'utilisateur a le rôle admin
          _role = 'admin';
          debugPrint('✅ Connexion réussie en tant qu\'Administrateur');
        } else {
          // L'utilisateur est un utilisateur normal
          _role = 'user';
          debugPrint('✅ Connexion réussie en tant qu\'utilisateur');
        }
      } catch (e) {
        debugPrint('❌ ERREUR lors de la requête users: $e');
        // En cas d'erreur, on le met en utilisateur normal par sécurité
        _role = 'user';
      }

      notifyListeners();
      debugPrint('✅ Rôle final: $_role');
      return response;
    } on AuthException catch (e) {
      debugPrint('❌ Erreur de connexion: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('❌ Erreur inattendue: $e');
      throw Exception('Erreur inconnue : $e');
    }
  }

  // ------------------------------------------------------------------
  // 🚪 Déconnexion
  // ------------------------------------------------------------------
  Future<void> logout() async {
    await _supabase.auth.signOut();
    _user = null;
    _role = null;
    notifyListeners();
    debugPrint('👋 Déconnexion effectuée');
  }

  // ------------------------------------------------------------------
  // 📞 Méthode pour obtenir le numéro de téléphone normalisé
  // ------------------------------------------------------------------
  String? get normalizedPhone {
    if (_user == null) return null;
    
    // Si c'est un email (admin), retourner null
    if (_user!.contains('@')) return null;
    
    // Si c'est un téléphone, le normaliser
    return normalizePhoneNumber(_user!);
  }
}
