class WhapiConfig {
  static const bool enableWhapi = true;

  /// URL API Whapi
  static const String baseUrl = 'https://gate.whapi.cloud';

  /// ⚠️ Ne pas mettre le token ici en production !!!
  /// Token fourni : LHdq7epYqlNkN6riPV6FHmCqvj5J0Y47
  static const String authToken = 'LHdq7epYqlNkN6riPV6FHmCqvj5J0Y47';

  /// Numéro expéditeur Whapi (format international sans + et sans zéro)
  /// DOIT correspondre au numéro admin qui reçoit les notifications
  /// Identique à AdminConfig.adminWhatsAppNumber = '24102621676'
  static const String senderNumber = '24102621676';
}



