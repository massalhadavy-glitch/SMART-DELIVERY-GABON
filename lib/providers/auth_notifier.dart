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

  // ------------------------------------------------------------------
  // 📧 Mettre à jour l'email de l'utilisateur
  // ------------------------------------------------------------------
  Future<void> updateEmail(String newEmail) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Aucun utilisateur connecté.');
      }

      // Valider le format de l'email
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(newEmail)) {
        throw Exception('Format d\'email invalide.');
      }

      // Mettre à jour l'email dans Supabase Auth
      await _supabase.auth.updateUser(
        UserAttributes(email: newEmail),
      );

      // Mettre à jour l'email dans la table public.users
      try {
        await _supabase
            .from('users')
            .update({'email': newEmail, 'updated_at': DateTime.now().toIso8601String()})
            .eq('id', currentUser.id);
        
        debugPrint('✅ Email mis à jour dans public.users');
      } catch (e) {
        debugPrint('⚠️ Erreur lors de la mise à jour dans public.users: $e');
        // On continue quand même car l'email dans auth.users est mis à jour
      }

      // Mettre à jour l'état local
      _user = newEmail;
      notifyListeners();
      
      debugPrint('✅ Email mis à jour avec succès: $newEmail');
    } on AuthException catch (e) {
      debugPrint('❌ Erreur de mise à jour d\'email: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('❌ Erreur inattendue lors de la mise à jour d\'email: $e');
      throw Exception('Erreur lors de la mise à jour de l\'email : $e');
    }
  }

  // ------------------------------------------------------------------
  // 🔐 Mettre à jour le mot de passe de l'utilisateur
  // ------------------------------------------------------------------
  Future<void> updatePassword(String newPassword) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Aucun utilisateur connecté.');
      }

      // Valider la force du mot de passe
      if (newPassword.length < 6) {
        throw Exception('Le mot de passe doit contenir au moins 6 caractères.');
      }

      // Mettre à jour le mot de passe dans Supabase Auth
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      debugPrint('✅ Mot de passe mis à jour avec succès');
    } on AuthException catch (e) {
      debugPrint('❌ Erreur de mise à jour de mot de passe: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('❌ Erreur inattendue lors de la mise à jour de mot de passe: $e');
      throw Exception('Erreur lors de la mise à jour du mot de passe : $e');
    }
  }

  // ------------------------------------------------------------------
  // 🔐 Vérifier le mot de passe actuel (pour confirmation avant changement)
  // ------------------------------------------------------------------
  Future<bool> verifyCurrentPassword(String password) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null || currentUser.email == null) {
        throw Exception('Aucun utilisateur connecté.');
      }

      // Tenter de se connecter avec le mot de passe actuel
      try {
        await _supabase.auth.signInWithPassword(
          email: currentUser.email!,
          password: password,
        );

        // Si on arrive ici, le mot de passe est correct
        // La session a été mise à jour par signInWithPassword, ce qui est correct
        debugPrint('✅ Mot de passe vérifié avec succès');
        return true;
      } on AuthException catch (e) {
        // Si le mot de passe est incorrect, la session actuelle reste intacte
        // car signInWithPassword n'a pas réussi
        debugPrint('❌ Mot de passe incorrect: ${e.message}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la vérification: $e');
      return false;
    }
  }
}
