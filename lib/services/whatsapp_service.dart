import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/whapi_config.dart';

class WhatsAppService {

  static Future<bool> sendOrderNotification({
    required String trackingNumber,
    required String pickupAddress,
    required String destinationAddress,
    required String packageType,
    required String deliveryType,
    required double totalCost,
    required String customerPhone,
  }) async {
    final String message = '''
🚚 *NOUVELLE COMMANDE - SMART DELIVERY*

📦 *Tracking:* $trackingNumber
📍 *Ramassage:* $pickupAddress
🏁 *Destination:* $destinationAddress
📦 *Type:* $packageType
🚀 *Livraison:* $deliveryType
💰 *Coût:* ${totalCost.toInt()} FCFA
📞 *Client:* $customerPhone
⏰ *Date:* ${DateTime.now().toString().split('.')[0]}

✅ *Statut:* En attente de collecte
''';

    return await _sendWhatsAppMessage(message);
  }

  static Future<bool> _sendWhatsAppMessage(String message) async {
    try {
      final url = Uri.parse('${WhapiConfig.baseUrl}/messages/text');

      final body = {
        "to": WhapiConfig.senderNumber, // admin number
        "text": message,
      };

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${WhapiConfig.authToken}",
      };

      final response =
          await http.post(url, headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Message WhatsApp envoyé !");
        return true;
      } else {
        print("❌ Erreur ${response.statusCode} : ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Exception envoi message: $e");
      return false;
    }
  }
}


