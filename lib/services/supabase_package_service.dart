import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/package.dart';

class SupabasePackageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Retourne un Stream de tous les colis
  Stream<List<Package>> getPackages() {
    try {
      print('🔍 Récupération des colis depuis Supabase...');
      return _supabase
          .from('packages')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .map((data) {
            print('📊 Données brutes reçues: ${data.length} entrées');
            final packages = data
                .map((row) {
                  try {
                    final package = Package.fromMap(row as Map<String, dynamic>);
                    print('📦 Colis parsé: ${package.trackingNumber} - ${package.status}');
                    return package;
                  } catch (e) {
                    print('❌ Erreur parsing colis: $e');
                    print('❌ Données problématiques: $row');
                    return null;
                  }
                })
                .where((package) => package != null)
                .cast<Package>()
                .toList();
            print('✅ ${packages.length} colis parsés avec succès');
            return packages;
          });
    } catch (e) {
      print('❌ Erreur getPackages: $e');
      return Stream.value([]);
    }
  }

  /// Ajoute un nouveau colis
  Future<void> addPackage(Package package) async {
    try {
      print('💾 Préparation de l\'ajout du colis: ${package.trackingNumber}');
      final data = package.toMap();
      data['created_at'] = DateTime.now().toIso8601String();
      
      print('📋 Données à insérer: $data');
      
      final result = await _supabase.from('packages').insert(data);
      print('✅ Colis inséré avec succès: $result');
    } catch (e) {
      print('❌ Erreur addPackage: $e');
      rethrow;
    }
  }

  /// Met à jour le statut d'un colis
  Future<void> updatePackageStatus(String packageId, String newStatus) async {
    try {
      print('🔄 ========== MISE À JOUR DU STATUT ==========');
      print('🔄 Package ID: $packageId');
      print('🔄 Nouveau statut: $newStatus');
      
      // Vérifier que l'utilisateur est authentifié
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        print('❌ ERREUR: Aucun utilisateur authentifié');
        throw Exception('Vous devez être connecté pour mettre à jour le statut d\'un colis');
      }
      
      print('✅ Utilisateur authentifié: ${currentUser.id} (${currentUser.email})');
      
      // Vérifier que l'utilisateur est admin (dans la table users)
      try {
        final userData = await _supabase
            .from('users')
            .select('role')
            .eq('id', currentUser.id)
            .maybeSingle();
        
        print('📊 Données utilisateur: $userData');
        
        if (userData == null || userData['role'] != 'admin') {
          print('❌ ERREUR: L\'utilisateur n\'est pas admin (rôle: ${userData?['role'] ?? 'non trouvé'})');
          throw Exception('Seuls les administrateurs peuvent mettre à jour le statut d\'un colis');
        }
        
        print('✅ Utilisateur confirmé comme admin');
      } catch (e) {
        if (e.toString().contains('Seuls les administrateurs')) {
          rethrow;
        }
        print('⚠️ Erreur lors de la vérification du rôle, tentative de mise à jour quand même: $e');
      }
      
      // Vérifier que le colis existe avant la mise à jour
      final existingPackage = await _supabase
          .from('packages')
          .select('id, tracking_number, status')
          .eq('tracking_number', packageId.toUpperCase())
          .maybeSingle();
      
      if (existingPackage == null) {
        print('❌ ERREUR: Colis non trouvé avec le tracking number: $packageId');
        throw Exception('Colis non trouvé avec le numéro de suivi: $packageId');
      }
      
      print('✅ Colis trouvé: ${existingPackage['tracking_number']} (statut actuel: ${existingPackage['status']})');
      
      // Effectuer la mise à jour
      print('🔄 Tentative de mise à jour dans Supabase...');
      final result = await _supabase
          .from('packages')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('tracking_number', packageId.toUpperCase())
          .select();
      
      print('📊 Résultat de la mise à jour: $result');
      
      if (result.isEmpty) {
        print('⚠️ Aucune ligne mise à jour, vérification...');
        // Vérifier à nouveau
        final verification = await _supabase
            .from('packages')
            .select('id, tracking_number, status')
            .eq('tracking_number', packageId.toUpperCase())
            .maybeSingle();
        
        if (verification != null && verification['status'] == newStatus) {
          print('✅ Mise à jour réussie (vérifiée)');
        } else {
          print('❌ La mise à jour semble avoir échoué');
          throw Exception('La mise à jour du statut a échoué. Vérifiez vos permissions.');
        }
      } else {
        print('✅ Statut mis à jour avec succès');
        print('✅ Nouveau statut confirmé: ${result[0]['status']}');
      }
      
      // Forcer la mise à jour du Stream en vérifiant la table
      final updatedPackage = await _supabase
          .from('packages')
          .select()
          .eq('tracking_number', packageId.toUpperCase())
          .maybeSingle();
      
      if (updatedPackage != null) {
        print('✅ Vérification finale: ${updatedPackage['tracking_number']} - ${updatedPackage['status']}');
      } else {
        print('⚠️ Colis non trouvé après mise à jour (peut être normal si le Stream se met à jour)');
      }
      
      print('🔄 ===========================================');
    } on PostgrestException catch (e) {
      print('❌ ERREUR PostgrestException: ${e.message}');
      print('❌ Code: ${e.code}');
      print('❌ Détails: ${e.details}');
      print('❌ Hint: ${e.hint}');
      
      String errorMessage = 'Erreur lors de la mise à jour du statut';
      if (e.message.contains('permission denied') || e.message.contains('new row violates row-level security')) {
        errorMessage = 'Permission refusée. Vérifiez que vous êtes bien connecté en tant qu\'administrateur.';
      } else if (e.message.contains('could not find')) {
        errorMessage = 'Colis non trouvé. Vérifiez le numéro de suivi.';
      } else {
        errorMessage = 'Erreur de base de données: ${e.message}';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      print('❌ ERREUR updatePackageStatus: $e');
      print('❌ Type d\'erreur: ${e.runtimeType}');
      rethrow;
    }
  }

  /// Vérifie si un utilisateur est administrateur
  Future<bool> isAdmin(String userId) async {
    try {
      print('🔍 Vérification admin pour userId: $userId');
      
      // Vérifier dans la table admins si l'utilisateur existe
      final response = await _supabase
          .from('admins')
          .select('admin_type')
          .eq('id', userId)
          .maybeSingle();

      print('📊 Réponse de la table admins: $response');

      if (response == null) {
        print('⚠️ Utilisateur non trouvé dans public.admins');
        return false;
      }

      final adminType = response['admin_type'];
      print('✅ Utilisateur est admin (type: $adminType)');
      
      return true;
    } catch (e) {
      print('❌ Erreur isAdmin: $e');
      return false;
    }
  }

  /// Récupère le type d'admin d'un utilisateur
  Future<String?> getAdminType(String userId) async {
    try {
      print('🔍 Récupération du type admin pour userId: $userId');
      
      final response = await _supabase
          .from('admins')
          .select('admin_type')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        print('⚠️ Utilisateur non trouvé dans public.admins');
        return null;
      }

      final adminType = response['admin_type'];
      print('✅ Type admin: $adminType');
      
      return adminType;
    } catch (e) {
      print('❌ Erreur getAdminType: $e');
      return null;
    }
  }

  /// Recherche un colis par numéro de suivi
  Future<Package?> getPackageByTrackingNumber(String trackingNumber) async {
    try {
      final response = await _supabase
          .from('packages')
          .select()
          .eq('tracking_number', trackingNumber.toUpperCase())
          .maybeSingle();

      if (response == null) return null;

      return Package.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      print('Erreur getPackageByTrackingNumber: $e');
      return null;
    }
  }
}

