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
      print('🔄 Mise à jour du statut pour: $packageId → $newStatus');
      
      final result = await _supabase
          .from('packages')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('tracking_number', packageId);
      
      print('✅ Statut mis à jour avec succès: $result');
      
      // Forcer la mise à jour du Stream en vérifiant la table
      final updatedPackage = await _supabase
          .from('packages')
          .select()
          .eq('tracking_number', packageId)
          .maybeSingle();
      
      if (updatedPackage != null) {
        print('✅ Vérification: ${updatedPackage['tracking_number']} - ${updatedPackage['status']}');
      }
    } catch (e) {
      print('❌ Erreur updatePackageStatus: $e');
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

