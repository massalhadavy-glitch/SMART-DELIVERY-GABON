/// Classe pour gérer les permissions des administrateurs
/// Différencie les accès entre super_admin et admin

class AdminPermissions {
  final String adminType;

  AdminPermissions(this.adminType);

  // ===================================
  // PERMISSIONS DES COLIS
  // ===================================
  
  /// Peut voir tous les colis
  bool get canViewPackages => adminType == 'super_admin' || adminType == 'admin';

  /// Peut créer un nouveau colis
  bool get canCreatePackage => adminType == 'super_admin' || adminType == 'admin';

  /// Peut modifier le statut d'un colis
  bool get canUpdatePackageStatus => adminType == 'super_admin' || adminType == 'admin';

  /// Peut supprimer un colis
  bool get canDeletePackage => adminType == 'super_admin'; // Seulement super_admin

  // ===================================
  // PERMISSIONS DES UTILISATEURS
  // ===================================

  /// Peut voir tous les utilisateurs
  bool get canViewUsers => adminType == 'super_admin' || adminType == 'admin';

  /// Peut créer un nouvel utilisateur
  bool get canCreateUser => adminType == 'super_admin';

  /// Peut modifier un utilisateur
  bool get canUpdateUser => adminType == 'super_admin';

  /// Peut supprimer un utilisateur
  bool get canDeleteUser => adminType == 'super_admin';

  // ===================================
  // PERMISSIONS DES ADMINS
  // ===================================

  /// Peut voir tous les admins
  bool get canViewAdmins => adminType == 'super_admin';

  /// Peut créer un nouvel admin
  bool get canCreateAdmin => adminType == 'super_admin';

  /// Peut promouvoir un utilisateur en admin
  bool get canPromoteToAdmin => adminType == 'super_admin';

  /// Peut rétrograder un admin
  bool get canDemoteAdmin => adminType == 'super_admin';

  /// Peut supprimer un admin
  bool get canDeleteAdmin => adminType == 'super_admin';

  // ===================================
  // PERMISSIONS SYSTÈME
  // ===================================

  /// Peut accéder aux paramètres avancés
  bool get canAccessAdvancedSettings => adminType == 'super_admin';

  /// Peut modifier les paramètres de l'application
  bool get canModifyAppSettings => adminType == 'super_admin';

  /// Peut voir les logs système
  bool get canViewSystemLogs => adminType == 'super_admin';

  /// Peut exporter les données
  bool get canExportData => adminType == 'super_admin' || adminType == 'admin';

  /// Peut importer des données
  bool get canImportData => adminType == 'super_admin';

  // ===================================
  // PERMISSIONS ANALYTIQUES
  // ===================================

  /// Peut voir les statistiques globales
  bool get canViewAnalytics => adminType == 'super_admin' || adminType == 'admin';

  /// Peut voir les statistiques détaillées
  bool get canViewDetailedAnalytics => adminType == 'super_admin';

  /// Peut générer des rapports
  bool get canGenerateReports => adminType == 'super_admin' || adminType == 'admin';

  // ===================================
  // PERMISSIONS NOTIFICATIONS
  // ===================================

  /// Peut envoyer des notifications
  bool get canSendNotifications => adminType == 'super_admin' || adminType == 'admin';

  /// Peut envoyer des notifications massives
  bool get canSendBulkNotifications => adminType == 'super_admin';

  // ===================================
  // PERMISSIONS FINANCIÈRES
  // ===================================

  /// Peut voir les informations financières
  bool get canViewFinancials => adminType == 'super_admin';

  /// Peut modifier les tarifs
  bool get canModifyPricing => adminType == 'super_admin';

  // ===================================
  // MÉTHODES UTILITAIRES
  // ===================================

  /// Vérifie si c'est un super admin
  bool get isSuperAdmin => adminType == 'super_admin';

  /// Vérifie si c'est un admin standard
  bool get isRegularAdmin => adminType == 'admin';

  /// Retourne le niveau de permission (plus élevé = plus de permissions)
  int get permissionLevel {
    switch (adminType) {
      case 'super_admin':
        return 2;
      case 'admin':
        return 1;
      default:
        return 0;
    }
  }

  /// Retourne le nom d'affichage du rôle
  String get displayName {
    switch (adminType) {
      case 'super_admin':
        return 'Super Administrateur';
      case 'admin':
        return 'Administrateur';
      default:
        return 'Utilisateur';
    }
  }

  /// Retourne la description du rôle
  String get roleDescription {
    switch (adminType) {
      case 'super_admin':
        return 'Accès complet à toutes les fonctionnalités';
      case 'admin':
        return 'Gestion des colis et suivi des livraisons';
      default:
        return 'Accès utilisateur standard';
    }
  }

  /// Retourne l'icône associée au rôle
  String get roleIcon {
    switch (adminType) {
      case 'super_admin':
        return '👑'; // Couronne
      case 'admin':
        return '🔑'; // Clé
      default:
        return '👤'; // Utilisateur
    }
  }

  /// Retourne la couleur associée au rôle (en hex)
  String get roleColor {
    switch (adminType) {
      case 'super_admin':
        return '#FFD700'; // Or
      case 'admin':
        return '#4169E1'; // Bleu royal
      default:
        return '#808080'; // Gris
    }
  }

  /// Vérifie si l'admin peut effectuer une action spécifique
  bool canPerform(String action) {
    switch (action.toLowerCase()) {
      // Colis
      case 'view_packages':
        return canViewPackages;
      case 'create_package':
        return canCreatePackage;
      case 'update_package':
        return canUpdatePackageStatus;
      case 'delete_package':
        return canDeletePackage;

      // Utilisateurs
      case 'view_users':
        return canViewUsers;
      case 'create_user':
        return canCreateUser;
      case 'update_user':
        return canUpdateUser;
      case 'delete_user':
        return canDeleteUser;

      // Admins
      case 'view_admins':
        return canViewAdmins;
      case 'create_admin':
        return canCreateAdmin;
      case 'promote_admin':
        return canPromoteToAdmin;
      case 'demote_admin':
        return canDemoteAdmin;
      case 'delete_admin':
        return canDeleteAdmin;

      // Système
      case 'access_settings':
        return canAccessAdvancedSettings;
      case 'modify_settings':
        return canModifyAppSettings;
      case 'view_logs':
        return canViewSystemLogs;
      case 'export_data':
        return canExportData;
      case 'import_data':
        return canImportData;

      // Analytics
      case 'view_analytics':
        return canViewAnalytics;
      case 'view_detailed_analytics':
        return canViewDetailedAnalytics;
      case 'generate_reports':
        return canGenerateReports;

      // Notifications
      case 'send_notifications':
        return canSendNotifications;
      case 'send_bulk_notifications':
        return canSendBulkNotifications;

      // Financières
      case 'view_financials':
        return canViewFinancials;
      case 'modify_pricing':
        return canModifyPricing;

      default:
        return false;
    }
  }

  /// Liste toutes les permissions accordées
  List<String> get grantedPermissions {
    List<String> permissions = [];

    if (canViewPackages) permissions.add('Voir les colis');
    if (canCreatePackage) permissions.add('Créer des colis');
    if (canUpdatePackageStatus) permissions.add('Modifier les colis');
    if (canDeletePackage) permissions.add('Supprimer des colis');

    if (canViewUsers) permissions.add('Voir les utilisateurs');
    if (canCreateUser) permissions.add('Créer des utilisateurs');
    if (canUpdateUser) permissions.add('Modifier les utilisateurs');
    if (canDeleteUser) permissions.add('Supprimer des utilisateurs');

    if (canViewAdmins) permissions.add('Voir les admins');
    if (canCreateAdmin) permissions.add('Créer des admins');
    if (canPromoteToAdmin) permissions.add('Promouvoir en admin');
    if (canDemoteAdmin) permissions.add('Rétrograder des admins');
    if (canDeleteAdmin) permissions.add('Supprimer des admins');

    if (canAccessAdvancedSettings) permissions.add('Paramètres avancés');
    if (canModifyAppSettings) permissions.add('Modifier les paramètres');
    if (canViewSystemLogs) permissions.add('Voir les logs');
    if (canExportData) permissions.add('Exporter les données');
    if (canImportData) permissions.add('Importer les données');

    if (canViewAnalytics) permissions.add('Voir les analytics');
    if (canViewDetailedAnalytics) permissions.add('Analytics détaillées');
    if (canGenerateReports) permissions.add('Générer des rapports');

    if (canSendNotifications) permissions.add('Envoyer des notifications');
    if (canSendBulkNotifications) permissions.add('Notifications massives');

    if (canViewFinancials) permissions.add('Voir les finances');
    if (canModifyPricing) permissions.add('Modifier les tarifs');

    return permissions;
  }

  @override
  String toString() {
    return 'AdminPermissions(type: $adminType, level: $permissionLevel, name: $displayName)';
  }
}

