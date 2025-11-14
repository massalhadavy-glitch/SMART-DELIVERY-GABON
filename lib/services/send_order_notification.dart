import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config/admin_config.dart';
import '../config/whapi_config.dart';

/// Service centralisé pour envoyer les notifications de commande à l'administrateur
/// Supporte l'API Whapi et le fallback vers l'URL WhatsApp directe
class SendOrderNotificationService {
  
  /// Envoie une notification WhatsApp à l'administrateur après qu'un client ait soumis une commande
  /// 
  /// Paramètres:
  /// - trackingNumber: Numéro de suivi du colis
  /// - pickupAddress: Adresse de ramassage
  /// - destinationAddress: Adresse de destination
  /// - packageType: Type de colis
  /// - deliveryType: Type de livraison (Express/Standard)
  /// - totalCost: Coût total
  /// - customerPhone: Numéro de téléphone du client
  /// - customerName: Nom du client
  /// 
  /// Retourne true si au moins une notification a été envoyée avec succès
  static Future<bool> sendNotificationToAdmin({
    required String trackingNumber,
    required String pickupAddress,
    required String destinationAddress,
    required String packageType,
    required String deliveryType,
    required double totalCost,
    required String customerPhone,
    String customerName = '',
    String recipientName = '',
    String recipientPhone = '',
    String paymentMethod = '',
  }) async {
    // Vérifier si les notifications sont activées
    if (!AdminConfig.enableWhatsAppNotifications) {
      debugPrint("⚠️ Notifications WhatsApp désactivées dans AdminConfig");
      return false;
    }

    // Debug pour vérifier que le nom est bien transmis
    debugPrint("📝 Nom de l'expéditeur reçu: '$customerName'");
    debugPrint("📝 Téléphone de l'expéditeur reçu: '$customerPhone'");
    
    // Construire le message de notification
    final String message = _buildOrderMessage(
      trackingNumber: trackingNumber,
      pickupAddress: pickupAddress,
      destinationAddress: destinationAddress,
      packageType: packageType,
      deliveryType: deliveryType,
      totalCost: totalCost,
      customerPhone: customerPhone,
      customerName: customerName,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      paymentMethod: paymentMethod,
    );

    // Récupérer la liste des numéros administrateurs
    final adminPhones = AdminConfig.adminWhatsAppNumbers;
    
    if (adminPhones.isEmpty) {
      debugPrint("⚠️ Aucun numéro administrateur configuré");
      return false;
    }

    debugPrint("════════════════════════════════════════");
    debugPrint("📨 ENVOI NOTIFICATIONS ADMINISTRATEUR");
    debugPrint("════════════════════════════════════════");
    debugPrint("📱 Numéros destinataires: ${adminPhones.length}");
    debugPrint("📝 Message length: ${message.length} caractères");

    int successCount = 0;
    int totalCount = adminPhones.length;

    // Envoyer à tous les administrateurs
    for (int i = 0; i < adminPhones.length; i++) {
      final adminPhone = adminPhones[i];
      
      debugPrint("════════════════════════════════════════");
      debugPrint("📨 Envoi ${i + 1}/$totalCount vers: $adminPhone");

      // Normaliser le numéro de l'admin
      final normalizedAdminPhone = normalizePhone(adminPhone);
      debugPrint("📱 Numéro normalisé: $normalizedAdminPhone");
      debugPrint("💡 Note: Les numéros WhatsApp Business reçoivent les messages automatiquement");
      debugPrint("💡 Note: Les numéros WhatsApp conventionnels nécessitent d'être dans les contacts du sender");

      bool success = false;

      // Si Whapi est activé, essayer d'envoyer via Whapi
      if (WhapiConfig.enableWhapi) {
        debugPrint("🔵 Tentative d'envoi via Whapi API...");
        success = await _sendViaWhapi(
          adminPhone: normalizedAdminPhone,
          message: message,
        );
        
        if (success) {
          debugPrint("✅ Notification envoyée via Whapi");
          successCount++;
        } else {
          debugPrint("⚠️ Échec Whapi - L'envoi automatique n'a pas pu être effectué");
          debugPrint("⚠️ Note: Le fallback WhatsApp URL ouvre WhatsApp sur l'appareil du client,");
          debugPrint("⚠️ pas sur l'appareil de l'admin. Il ne peut pas envoyer automatiquement.");
          // Ne pas utiliser le fallback WhatsApp URL car il ouvre WhatsApp sur le client
          // au lieu d'envoyer directement à l'admin
        }
      }

      debugPrint("════════════════════════════════════════");
    }

    debugPrint("════════════════════════════════════════");
    debugPrint("📊 RÉSUMÉ ENVOI NOTIFICATIONS");
    debugPrint("════════════════════════════════════════");
    debugPrint("✅ Succès: $successCount/$totalCount");
    debugPrint("════════════════════════════════════════");

    return successCount > 0;
  }

  /// Envoie une notification via l'API Whapi
  static Future<bool> _sendViaWhapi({
    required String adminPhone,
    required String message,
  }) async {
    try {
      // Construire l'URL de l'endpoint Whapi
      final url = Uri.parse('${WhapiConfig.baseUrl}/messages/text');
      
      // Format simple avec "to" (string) et "body" (message)
      // L'API Whapi attend "to" comme string direct, pas comme objet
      Map<String, dynamic> body = {
        "to": adminPhone, // Destinataire (numéro admin qui reçoit)
        "body": message, // Message de notification
      };

      // Headers avec le token d'authentification
      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${WhapiConfig.authToken}",
      };

      debugPrint("🔍 Format Whapi: {to: string, body: string}");
      debugPrint("📥 To (destinataire/admin): $adminPhone");
      debugPrint("📝 Body length: ${message.length} caractères");
      debugPrint("🌐 URL: $url");
      debugPrint("🔑 Token: ${WhapiConfig.authToken.substring(0, 10)}...");
      debugPrint("📦 Body JSON: ${jsonEncode(body)}");

      // Envoyer la requête POST
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint("⏱️ Timeout lors de l'envoi Whapi");
          throw TimeoutException("Timeout lors de l'envoi Whapi");
        },
      );

      // Afficher la réponse complète
      debugPrint("════════════════════════════════════════");
      debugPrint("📊 Réponse Whapi");
      debugPrint("════════════════════════════════════════");
      debugPrint("📊 Status Code: ${response.statusCode}");
      debugPrint("📄 Response Body (RAW): ${response.body}");

      // Vérifier le statut de la réponse
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final responseData = jsonDecode(response.body);
          debugPrint("📋 Réponse parsée: $responseData");
          
          // Vérifier si la réponse contient un statut de succès ou d'échec
          if (responseData is Map) {
            // Vérifier le statut dans la réponse
            if (responseData.containsKey('status')) {
              final status = responseData['status'];
              debugPrint("📊 Status dans la réponse: $status");
              
              // Si le statut indique un échec malgré un code HTTP 200
              if (status.toString().toLowerCase().contains('fail') || 
                  status.toString().toLowerCase().contains('error')) {
                debugPrint("⚠️ Statut d'échec détecté malgré code HTTP 200");
                debugPrint("💡 Cause probable: Le numéro $adminPhone n'est peut-être pas un WhatsApp Business");
                debugPrint("💡 Ou le numéro n'a pas accepté de recevoir des messages depuis ce sender");
                return false;
              }
            }
            
            // Vérifier s'il y a un message d'erreur dans la réponse
            if (responseData.containsKey('error')) {
              final error = responseData['error'];
              debugPrint("❌ Erreur détectée dans la réponse: $error");
              return false;
            }
            
            // Vérifier si le message a été envoyé avec succès
            if (responseData.containsKey('sent') && responseData['sent'] == false) {
              debugPrint("⚠️ Message non envoyé pour $adminPhone");
              debugPrint("💡 Cause probable: Numéro WhatsApp conventionnel (non Business)");
              debugPrint("💡 Solution: Utiliser un numéro WhatsApp Business ou ajouter le numéro aux contacts");
              return false;
            }
          }
          
          debugPrint("✅ Succès Whapi pour $adminPhone");
          return true;
        } catch (e) {
          debugPrint("⚠️ Réponse 200 mais JSON invalide: $e");
          // Même si le JSON est invalide, un 200 est généralement un succès
          return true;
        }
      } else {
        // Erreur HTTP
        try {
          final errorData = jsonDecode(response.body);
          debugPrint("❌ ERREUR WHAPI pour $adminPhone: Status ${response.statusCode}");
          debugPrint("📄 Réponse détaillée: ${jsonEncode(errorData)}");
          
          // Messages d'erreur spécifiques pour les numéros WhatsApp conventionnels
          String errorMessage = '';
          if (errorData is Map) {
            if (errorData.containsKey('error')) {
              final error = errorData['error'];
              if (error is Map) {
                errorMessage = error['message'] ?? error.toString();
                debugPrint("📋 Message d'erreur: $errorMessage");
                
                // Vérifier si l'erreur concerne un numéro non-Business
                if (errorMessage.toLowerCase().contains('business') ||
                    errorMessage.toLowerCase().contains('contact') ||
                    errorMessage.toLowerCase().contains('not found') ||
                    errorMessage.toLowerCase().contains('invalid')) {
                  debugPrint("⚠️ PROBLÈME DÉTECTÉ: Le numéro $adminPhone semble avoir un problème");
                  debugPrint("💡 Causes possibles:");
                  debugPrint("   - Numéro WhatsApp conventionnel (non Business)");
                  debugPrint("   - Numéro non ajouté aux contacts du sender");
                  debugPrint("   - Numéro invalide ou non enregistré sur WhatsApp");
                }
              } else if (error is String) {
                errorMessage = error;
                debugPrint("📋 Message d'erreur (string): $errorMessage");
              }
            } else {
              debugPrint("📋 Erreur complète: ${errorData.toString()}");
            }
          }
          
          debugPrint("❌ Échec d'envoi pour $adminPhone");
        } catch (e) {
          debugPrint("❌ ERREUR WHAPI pour $adminPhone: Status ${response.statusCode}");
          debugPrint("📄 Response Body: ${response.body}");
        }
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Exception lors de l'envoi Whapi: $e");
      debugPrint("📚 Stack trace: $stackTrace");
      return false;
    }
  }

  /// Envoie une notification via l'URL WhatsApp directe (fallback)
  static Future<bool> _sendViaWhatsAppUrl({
    required String phone,
    required String message,
  }) async {
    try {
      // Encoder le message pour l'URL
      final encodedMessage = Uri.encodeComponent(message);
      
      // Essayer différents schémas d'URL WhatsApp
      final urlSchemes = [
        'whatsapp://send?phone=$phone&text=$encodedMessage',
        'https://wa.me/$phone?text=$encodedMessage',
        'http://wa.me/$phone?text=$encodedMessage',
      ];
      
      for (final urlScheme in urlSchemes) {
        try {
          final uri = Uri.parse(urlScheme);
          debugPrint("🔗 Tentative avec: $urlScheme");
          
          if (await canLaunchUrl(uri)) {
            final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
            if (launched) {
              debugPrint("✅ WhatsApp ouvert avec succès");
              return true;
            }
          }
        } catch (e) {
          debugPrint("⚠️ Échec avec $urlScheme: $e");
          continue;
        }
      }
      
      debugPrint("❌ Impossible d'ouvrir WhatsApp avec aucun schéma d'URL");
      return false;
    } catch (e) {
      debugPrint("❌ Exception lors de l'envoi via URL: $e");
      return false;
    }
  }

  /// Construit le message de notification formaté
  static String _buildOrderMessage({
    required String trackingNumber,
    required String pickupAddress,
    required String destinationAddress,
    required String packageType,
    required String deliveryType,
    required double totalCost,
    required String customerPhone,
    String customerName = '',
    String recipientName = '',
    String recipientPhone = '',
    String paymentMethod = '',
  }) {
    // Construire la section destinataire si les informations sont disponibles
    String recipientSection = '';
    if (recipientName.isNotEmpty || recipientPhone.isNotEmpty) {
      recipientSection = '\n👤 *Destinataire:*';
      if (recipientName.isNotEmpty) {
        recipientSection += '\n   • Nom: $recipientName';
      }
      if (recipientPhone.isNotEmpty) {
        recipientSection += '\n   • Téléphone: $recipientPhone';
      }
    }
    
    // Construire la section paiement si le mode de paiement est disponible
    String paymentSection = '';
    if (paymentMethod.isNotEmpty) {
      paymentSection = '\n💳 *Paiement:* $paymentMethod';
    }
    
    // Construire la section client avec nom et numéro
    String clientInfo = customerPhone;
    final trimmedCustomerName = customerName.trim();
    if (trimmedCustomerName.isNotEmpty) {
      clientInfo = '$trimmedCustomerName - $customerPhone';
    }
    
    return '''
🚚 *NOUVELLE COMMANDE - SMART DELIVERY*

📦 *Tracking:* $trackingNumber
📍 *Ramassage:* $pickupAddress
🏁 *Destination:* $destinationAddress
📦 *Type:* $packageType
🚀 *Livraison:* $deliveryType
💰 *Coût:* ${totalCost.toInt()} FCFA$paymentSection
📞 *Client:* $clientInfo$recipientSection
⏰ *Date:* ${DateTime.now().toString().split('.')[0]}

✅ *Statut:* En attente de collecte
''';
  }

  /// Normalise un numéro de téléphone pour l'API Whapi
  /// Convertit différents formats (0XXXXXXXX, 241XXXXXXXX, +241XXXXXXXX) en format 241XXXXXXXX
  static String normalizePhone(String phone) {
    if (phone.isEmpty) return phone;
    
    // Supprimer tous les espaces, tirets, et autres caractères non numériques sauf +
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Si le numéro commence par +, le supprimer
    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }
    
    // Si le numéro commence par 0 (format local), remplacer par 241
    if (cleaned.startsWith('0') && cleaned.length >= 9) {
      cleaned = '241' + cleaned.substring(1);
    }
    
    // Si le numéro ne commence pas par 241, l'ajouter (pour le Gabon)
    if (!cleaned.startsWith('241') && cleaned.length >= 9) {
      // Si le numéro a 9 chiffres, on assume qu'il manque le code pays
      if (cleaned.length == 9) {
        cleaned = '241' + cleaned;
      } else if (cleaned.length > 9 && !cleaned.startsWith('241')) {
        cleaned = '241' + cleaned;
      }
    }
    
    return cleaned;
  }
}

/// Exception personnalisée pour les timeouts
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}

