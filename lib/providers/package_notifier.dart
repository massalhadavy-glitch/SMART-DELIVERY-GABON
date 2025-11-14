// Fichier : lib/providers/package_notifier.dart
import 'package:flutter/material.dart';
import '../models/package.dart';
import '../services/supabase_package_service.dart';
import 'auth_notifier.dart';

// PackageNotifier étend ChangeNotifier pour notifier l'UI des changements
class PackageNotifier extends ChangeNotifier {
  final SupabasePackageService _supabaseService = SupabasePackageService();
  final AuthNotifier _authNotifier;
  bool _disposed = false;

  List<Package> _allPackages = []; // Tous les colis de Supabase
  List<Package> _packages = []; // Colis filtrés selon l'utilisateur
  // Cache des colis par utilisateur - les colis restent en mémoire même après déconnexion
  final Map<String, List<Package>> _userPackagesCache = {};

  List<Package> get packages => _packages;

  PackageNotifier(this._authNotifier) {
    print('🔄 PackageNotifier initialisé - Début de l\'écoute des colis');
    
    // Écoute les changements d'authentification pour re-filtrer les colis
    _authNotifier.addListener(_onAuthChanged);
    
    // Écoute le flux de colis de Supabase et met à jour l'état local
    _supabaseService.getPackages().listen((packageList) {
      if (_disposed) return;
      print('📦 Colis reçus: ${packageList.length} colis');
      _allPackages = packageList;
      _filterPackagesForCurrentUser();
      notifyListeners();
    }, onError: (error) {
      if (_disposed) return;
      print('❌ Erreur lors du chargement des colis: $error');
      // En cas d'erreur, initialiser avec une liste vide
      _allPackages = [];
      _packages = [];
      notifyListeners();
    });
  }

  /// Appelé quand l'état d'authentification change (connexion/déconnexion)
  void _onAuthChanged() {
    if (_disposed) return;
    print('🔄 État d\'authentification changé - Re-filtrage des colis');
    _filterPackagesForCurrentUser();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    // Retirer le listener pour éviter les fuites mémoire
    _authNotifier.removeListener(_onAuthChanged);
    super.dispose();
  }

  /// Filtre les colis selon l'utilisateur connecté
  void _filterPackagesForCurrentUser() {
    if (_authNotifier.isAdmin) {
      // L'admin voit tous les colis
      _packages = List.from(_allPackages);
      print('👑 Admin voit tous les colis: ${_packages.length}');
    } else if (_authNotifier.isAuthenticated && _authNotifier.user != null) {
      // Le client ne voit que ses colis (basés sur son numéro de téléphone)
      final userPhone = _authNotifier.user!;
      final normalizedUserPhone = _normalizePhoneForComparison(userPhone);
      
      print('🔍 Filtrage pour utilisateur connecté: $userPhone (normalisé: $normalizedUserPhone)');
      print('🔍 Total colis disponibles: ${_allPackages.length}');
      
      // Filtrer les colis de l'utilisateur
      _packages = _allPackages.where((package) {
        // Comparer avec client_phone_number ou sender_phone
        final packagePhone = package.clientPhoneNumber;
        final senderPhone = package.senderPhone;
        
        // Normaliser les numéros pour la comparaison
        final normalizedPackagePhone = _normalizePhoneForComparison(packagePhone);
        final normalizedSenderPhone = _normalizePhoneForComparison(senderPhone);
        
        print('🔍 Colis ${package.trackingNumber}: clientPhone=$packagePhone (norm: $normalizedPackagePhone), senderPhone=$senderPhone (norm: $normalizedSenderPhone)');
        
        final matches = normalizedUserPhone.isNotEmpty && 
                       normalizedPackagePhone.isNotEmpty &&
                       (normalizedUserPhone == normalizedPackagePhone || 
                        normalizedUserPhone == normalizedSenderPhone);
        
        if (matches) {
          print('✅ Colis trouvé pour $userPhone: ${package.trackingNumber}');
        }
        
        return matches;
      }).toList();
      
      // Mettre à jour le cache pour cet utilisateur
      _userPackagesCache[normalizedUserPhone] = List.from(_packages);
      print('👤 Client $userPhone voit ${_packages.length} colis (mis en cache)');
      
      if (_packages.isEmpty && _allPackages.isNotEmpty) {
        print('⚠️ ATTENTION: Utilisateur connecté mais aucun colis trouvé!');
        print('⚠️ Vérifiez que le numéro de téléphone correspond: $userPhone');
        print('⚠️ Numéros dans les colis:');
        for (var pkg in _allPackages.take(5)) {
          print('   - ${pkg.trackingNumber}: client=${pkg.clientPhoneNumber}, sender=${pkg.senderPhone}');
        }
      }
    } else {
      // Utilisateur non connecté - Afficher tous les colis (pour permettre la consultation)
      // Les visiteurs peuvent voir les colis même sans être connectés
      _packages = List.from(_allPackages);
      print('👥 Utilisateur non connecté - Affichage de tous les colis: ${_packages.length}');
      print('💡 Note: Pour voir uniquement vos colis, connectez-vous avec votre numéro de téléphone');
    }
  }
  
  /// Récupère les colis d'un utilisateur depuis le cache (même après déconnexion)
  List<Package> getUserPackagesFromCache(String userPhone) {
    final normalizedPhone = _normalizePhoneForComparison(userPhone);
    return _userPackagesCache[normalizedPhone] ?? [];
  }
  
  /// Réinitialise la liste des colis d'un utilisateur (seulement pour l'admin)
  /// Cette méthode supprime les colis du cache mémoire seulement (pas de la base de données)
  /// Les colis restent en mémoire jusqu'à ce que l'admin fasse un reset
  Future<void> resetUserPackages(String userPhone, {bool requireAdmin = true}) async {
    if (requireAdmin && !_authNotifier.isAdmin) {
      throw Exception('Seul un administrateur peut réinitialiser les colis d\'un utilisateur');
    }
    
    final normalizedPhone = _normalizePhoneForComparison(userPhone);
    print('🗑️ Réinitialisation des colis en mémoire pour l\'utilisateur: $userPhone');
    
    // Retirer de la liste globale les colis de cet utilisateur (cache mémoire seulement)
    _allPackages.removeWhere((package) {
      final packagePhone = package.clientPhoneNumber;
      final senderPhone = package.senderPhone;
      final normalizedPackagePhone = _normalizePhoneForComparison(packagePhone);
      final normalizedSenderPhone = _normalizePhoneForComparison(senderPhone);
      
      return normalizedPhone == normalizedPackagePhone || 
             normalizedPhone == normalizedSenderPhone;
    });
    
    // Vider le cache pour cet utilisateur
    _userPackagesCache.remove(normalizedPhone);
    
    // Re-filtrer si l'utilisateur est actuellement connecté
    if (_authNotifier.isAuthenticated && 
        _normalizePhoneForComparison(_authNotifier.user ?? '') == normalizedPhone) {
      _filterPackagesForCurrentUser();
    }
    
    notifyListeners();
    print('✅ Colis de l\'utilisateur $userPhone réinitialisés (cache mémoire vidé)');
  }

  /// Normalise un numéro de téléphone pour la comparaison
  /// Retourne toujours un format normalisé : +241XXXXXXXX (12 caractères)
  String _normalizePhoneForComparison(String phone) {
    if (phone.isEmpty) return '';
    
    // Supprimer tous les caractères non numériques (espaces, tirets, parenthèses, etc.)
    String numericPhone = phone.replaceAll(RegExp(r'\D'), '');
    
    if (numericPhone.isEmpty) return '';
    
    // Si le numéro commence déjà par +, enlever le +
    if (phone.startsWith('+')) {
      // numericPhone contient déjà tout sauf les caractères non numériques
    }
    
    // Convertir en format +241XXXXXXXX (12 caractères au total)
    // Format gabonais : code pays 241 + 8 chiffres
    
    // Cas 1: Déjà avec code pays 241 (11 chiffres: 241XXXXXXXX)
    if (numericPhone.startsWith('241') && numericPhone.length == 11) {
      return '+$numericPhone';
    }
    
    // Cas 2: Juste les 8 chiffres locaux
    if (numericPhone.length == 8) {
      return '+241$numericPhone';
    }
    
    // Cas 3: Commence par 0 + 8 chiffres (9 chiffres: 0XXXXXXXX)
    if (numericPhone.startsWith('0') && numericPhone.length == 9) {
      numericPhone = numericPhone.substring(1); // Enlever le 0
      if (numericPhone.length == 8) {
        return '+241$numericPhone';
      }
    }
    
    // Cas 4: Format avec + déjà présent dans la string originale
    if (phone.contains('+241') && numericPhone.length >= 8) {
      // Extraire les 8 derniers chiffres
      if (numericPhone.length == 11 && numericPhone.startsWith('241')) {
        return '+$numericPhone';
      }
      // Si on a plus de chiffres, prendre les 8 derniers
      if (numericPhone.length > 8) {
        final last8 = numericPhone.substring(numericPhone.length - 8);
        return '+241$last8';
      }
    }
    
    // Si aucun format reconnu, essayer de trouver 8 chiffres consécutifs
    if (numericPhone.length >= 8) {
      // Prendre les 8 derniers chiffres
      final last8 = numericPhone.substring(numericPhone.length - 8);
      return '+241$last8';
    }
    
    // En dernier recours, retourner tel quel (sera comparé tel quel)
    print('⚠️ Format de téléphone non reconnu: $phone (numérique: $numericPhone)');
    return phone;
  }

  // CORRECTION: Ajout de la méthode addPackage
  Future<void> addPackage(Package newPackage) async {
    try {
      print('📝 ========== AJOUT D\'UN NOUVEAU COLIS ==========');
      print('📝 Tracking Number: ${newPackage.trackingNumber}');
      print('📝 Statut initial: ${newPackage.status}');
      print('📝 Client Phone: ${newPackage.clientPhoneNumber}');
      print('📝 Sender Phone: ${newPackage.senderPhone}');
      print('📝 Utilisateur actuel: ${_authNotifier.user}');
      print('📝 Est authentifié: ${_authNotifier.isAuthenticated}');
      print('📝 Est admin: ${_authNotifier.isAdmin}');
      print('📝 Total colis avant ajout: ${_allPackages.length}');
      
      // Appel au service pour sauvegarder le nouveau colis dans la base de données
      await _supabaseService.addPackage(newPackage);
      
      print('✅ Colis ajouté avec succès dans Supabase');
      
      // Ajouter temporairement à la liste locale pour un feedback immédiat
      // AVANT que le Stream Supabase mette à jour
      _allPackages.insert(0, newPackage);
      print('📦 Colis ajouté à _allPackages. Total maintenant: ${_allPackages.length}');
      
      // Mettre à jour le cache utilisateur si applicable
      if (newPackage.clientPhoneNumber.isNotEmpty || newPackage.senderPhone.isNotEmpty) {
        final userPhone = newPackage.clientPhoneNumber.isNotEmpty 
            ? newPackage.clientPhoneNumber 
            : newPackage.senderPhone;
        final normalizedPhone = _normalizePhoneForComparison(userPhone);
        
        print('💾 Normalisation téléphone: $userPhone → $normalizedPhone');
        
        // Ajouter au cache utilisateur
        if (!_userPackagesCache.containsKey(normalizedPhone)) {
          _userPackagesCache[normalizedPhone] = [];
        }
        _userPackagesCache[normalizedPhone]!.insert(0, newPackage);
        print('💾 Colis ajouté au cache utilisateur: $userPhone (normalisé: $normalizedPhone)');
      }
      
      // Re-filtrer et notifier pour mise à jour immédiate
      print('🔄 Re-filtrage des colis...');
      _filterPackagesForCurrentUser();
      
      print('📊 Résultat du filtrage:');
      print('   - Total colis (_allPackages): ${_allPackages.length}');
      print('   - Colis filtrés (_packages): ${_packages.length}');
      
      notifyListeners();
      
      print('✅ NotifyListeners() appelé - L\'UI devrait se mettre à jour');
      print('✅ Colis visible immédiatement pour l\'utilisateur et l\'administrateur');
      print('📝 ============================================');
      
      // La mise à jour définitive se fera via l'écouteur du Stream Supabase
      // Le Stream peut prendre quelques millisecondes, mais l'UI est déjà à jour
      
    } catch (e) {
      print('❌ Erreur lors de l\'ajout du colis: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<void> updatePackageStatus(String packageId, String newStatus) async {
    try {
      print('🔄 PackageNotifier - Mise à jour du statut pour: $packageId → $newStatus');
      await _supabaseService.updatePackageStatus(packageId, newStatus);
      
      // Mettre à jour manuellement dans la liste locale pour un feedback immédiat
      final index = _allPackages.indexWhere((pkg) => pkg.trackingNumber == packageId);
      if (index != -1) {
        print('✅ Colis trouvé dans la liste locale, mise à jour du statut...');
        _allPackages[index] = _allPackages[index].copyWith(status: newStatus);
        _filterPackagesForCurrentUser();
        notifyListeners();
        print('✅ Statut mis à jour dans la liste locale: $newStatus');
      } else {
        print('⚠️ Colis non trouvé dans la liste locale, le Stream devrait le mettre à jour');
      }
    } catch (e) {
      print('❌ Erreur lors de la mise à jour du statut: $e');
      rethrow;
    }
    // La mise à jour définitive se fera via l'écouteur du Stream
  }

  /// Recherche un colis par son numéro de suivi
  /// Recherche dans TOUS les colis (pas seulement ceux de l'utilisateur)
  Package? getPackageByTrackingNumber(String trackingNumber) {
    try {
      // Normaliser le numéro de suivi pour la recherche
      final normalizedTracking = trackingNumber.trim().toUpperCase();
      
      // Rechercher dans tous les colis, pas seulement ceux filtrés
      return _allPackages.firstWhere(
        (pkg) => pkg.trackingNumber.toUpperCase() == normalizedTracking,
      );
    } catch (e) {
      // Si pas trouvé dans la liste locale
      print('⚠️ Colis $trackingNumber non trouvé dans la liste locale');
      return null;
    }
  }

  /// Recherche un colis par son numéro de suivi dans Supabase (recherche directe en base)
  Future<Package?> getPackageByTrackingNumberFromSupabase(String trackingNumber) async {
    try {
      return await _supabaseService.getPackageByTrackingNumber(trackingNumber);
    } catch (e) {
      print('❌ Erreur lors de la recherche dans Supabase: $e');
      return null;
    }
  }

  /// Méthode de débogage pour forcer le rechargement
  Future<void> refreshPackages() async {
    try {
      print('🔄 Rechargement forcé des colis...');
      final packages = await _supabaseService.getPackages().first;
      _allPackages = packages;
      _filterPackagesForCurrentUser();
      notifyListeners();
      print('✅ ${packages.length} colis rechargés, ${_packages.length} visibles pour l\'utilisateur actuel');
    } catch (e) {
      print('❌ Erreur lors du rechargement: $e');
    }
  }

  /// Méthode de débogage pour afficher l'état actuel
  void debugPrintState() {
    print('🔍 État actuel du PackageNotifier:');
    print('📦 Nombre total de colis: ${_allPackages.length}');
    print('📦 Nombre de colis visibles: ${_packages.length}');
    print('👤 Utilisateur actuel: ${_authNotifier.user} (${_authNotifier.role})');
    for (var package in _packages) {
      print('  - ${package.trackingNumber}: ${package.status}');
    }
  }

  /// Méthode pour re-filtrer les colis quand l'utilisateur change
  void refreshUserPackages() {
    print('🔄 Re-filtrage des colis pour le nouvel utilisateur...');
    _filterPackagesForCurrentUser();
    notifyListeners();
  }
}