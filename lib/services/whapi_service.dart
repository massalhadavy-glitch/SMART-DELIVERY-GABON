import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../config/whapi_config.dart';

class WhapiService {
  /// Envoie un message via Whapi au numéro administrateur (destinataire)
  static Future<bool> sendOrderNotification({
    required String toPhoneWithoutPlus,
    required String message,
  }) async {
    if (!WhapiConfig.enableWhapi) return false;
    if (WhapiConfig.baseUrl.isEmpty || WhapiConfig.authToken.isEmpty) {
      debugPrint('⚠️ Whapi désactivé ou non configuré.');
      return false;
    }

    // S'assurer que l'URL utilise HTTPS (TLS)
    String baseUrl = WhapiConfig.baseUrl;
    if (!baseUrl.startsWith('https://')) {
      baseUrl = baseUrl.replaceFirst('http://', 'https://');
      debugPrint('⚠️ URL Whapi convertie en HTTPS pour la sécurité');
    }
    
    final uri = Uri.parse('$baseUrl/messages/text');

    final payload = {
      'to': toPhoneWithoutPlus, // format sans +
      'from': WhapiConfig.senderNumber,
      'message': message,
    };

    // Utiliser HttpClient avec HTTPS forcé
    final client = HttpClient();
    try {
      // Forcer HTTPS pour la sécurité TLS
      final request = await client.postUrl(uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer ${WhapiConfig.authToken}');
      request.add(utf8.encode(jsonEncode(payload)));

      final response = await request.close();
      final respBody = await response.transform(utf8.decoder).join();
      debugPrint('📨 Whapi response [${response.statusCode}]: $respBody');

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('❌ Whapi error: $e');
      return false;
    } finally {
      client.close(force: true);
    }
  }
}































