/// Configuration de l'administrateur - FICHIER EXEMPLE
/// 
/// INSTRUCTIONS:
/// 1. Copiez ce fichier et renommez-le en 'admin_config.dart'
/// 2. Remplacez 'XXXXXXXXX' par le vrai numéro WhatsApp de l'administrateur
/// 3. Format du numéro: code pays + numéro (exemple pour le Gabon: 241074123456)
/// 4. Ne partagez jamais le fichier admin_config.dart sur Git

class AdminConfig {
  // Numéro WhatsApp de l'administrateur
  // Format: code pays + numéro sans espaces ni caractères spéciaux
  // Exemple pour le Gabon: 241074123456 (241 = code pays du Gabon)
  static const String adminWhatsAppNumber = '241XXXXXXXXX';
  
  // Vous pouvez également ajouter d'autres contacts
  static const String adminEmail = 'admin@smartdelivery.ga';
  static const String adminName = 'Smart Delivery Admin';
  
  // Configuration supplémentaire
  static const bool enableWhatsAppNotifications = true;
  static const bool enableEmailNotifications = false;
}





















