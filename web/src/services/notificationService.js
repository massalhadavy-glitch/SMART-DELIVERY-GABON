// Service pour envoyer les notifications WhatsApp à l'administrateur
// Basé sur le service Flutter SendOrderNotificationService

const ADMIN_CONFIG = {
  enableWhatsAppNotifications: true,
  adminWhatsAppNumbers: [
    '24177773627',  // Premier numéro admin
    '24176554820',  // Deuxième numéro admin (WhatsApp Business)
  ],
};

const WHAPI_CONFIG = {
  enableWhapi: true,
  baseUrl: 'https://gate.whapi.cloud',
  authToken: 'LHdq7epYqlNkN6riPV6FHmCqvj5J0Y47',
};

/**
 * Normalise un numéro de téléphone pour l'API Whapi
 * Convertit différents formats en format 241XXXXXXXX
 */
function normalizePhone(phone) {
  if (!phone) return phone;
  
  // Supprimer tous les espaces, tirets, et autres caractères non numériques sauf +
  let cleaned = phone.replace(/[^\d+]/g, '');
  
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
    if (cleaned.length === 9) {
      cleaned = '241' + cleaned;
    } else if (cleaned.length > 9 && !cleaned.startsWith('241')) {
      cleaned = '241' + cleaned;
    }
  }
  
  return cleaned;
}

/**
 * Construit le message de notification formaté
 */
function buildOrderMessage({
  trackingNumber,
  pickupAddress,
  destinationAddress,
  packageType,
  deliveryType,
  totalCost,
  customerPhone,
  customerName = '',
  recipientName = '',
  recipientPhone = '',
  paymentMethod = '',
}) {
  // Construire la section destinataire si les informations sont disponibles
  let recipientSection = '';
  if (recipientName || recipientPhone) {
    recipientSection = '\n👤 *Destinataire:*';
    if (recipientName) {
      recipientSection += `\n   • Nom: ${recipientName}`;
    }
    if (recipientPhone) {
      recipientSection += `\n   • Téléphone: ${recipientPhone}`;
    }
  }
  
  // Construire la section paiement si le mode de paiement est disponible
  let paymentSection = '';
  if (paymentMethod) {
    paymentSection = `\n💳 *Paiement:* ${paymentMethod}`;
  }
  
  // Construire la section client avec nom et numéro
  let clientInfo = customerPhone;
  const trimmedCustomerName = customerName.trim();
  if (trimmedCustomerName) {
    clientInfo = `${trimmedCustomerName} - ${customerPhone}`;
  }
  
  const now = new Date().toISOString().split('.')[0].replace('T', ' ');
  
  return `🚚 *NOUVELLE COMMANDE - SMART DELIVERY*

📦 *Tracking:* ${trackingNumber}
📍 *Ramassage:* ${pickupAddress}
🏁 *Destination:* ${destinationAddress}
📦 *Type:* ${packageType}
🚀 *Livraison:* ${deliveryType}
💰 *Coût:* ${Math.round(totalCost)} FCFA${paymentSection}
📞 *Client:* ${clientInfo}${recipientSection}
⏰ *Date:* ${now}

✅ *Statut:* En attente de collecte
`;
}

/**
 * Envoie une notification via l'API Whapi via Supabase Edge Function
 * Utilise une fonction serverless pour contourner les problèmes CORS
 */
async function sendViaWhapi(adminPhone, message) {
  // Essayer d'abord avec l'Edge Function si disponible, sinon essayer directement
  const tryEdgeFunction = true; // Activez après déploiement de la fonction
  
  if (tryEdgeFunction) {
    try {
      // Appel via Supabase Edge Function
      const { supabase } = await import('../config/supabase');
      const { data, error } = await supabase.functions.invoke('send-whatsapp-notification', {
        body: {
          to: adminPhone,
          message: message,
        },
      });
      
      if (error) {
        console.warn('⚠️ Erreur Edge Function, tentative directe...', error);
        // Continuer avec l'appel direct en cas d'échec
      } else if (data && data.success) {
        console.log('✅ Notification envoyée via Edge Function');
        return true;
      } else {
        console.warn('⚠️ Edge Function retourné un échec, tentative directe...');
      }
    } catch (edgeError) {
      console.warn('⚠️ Edge Function non disponible, tentative directe...', edgeError.message);
      // Continuer avec l'appel direct
    }
  }
  
  // Tentative directe (peut échouer à cause de CORS)
  try {
    const url = `${WHAPI_CONFIG.baseUrl}/messages/text`;
    
    const body = {
      to: adminPhone,
      body: message,
    };

    const headers = {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${WHAPI_CONFIG.authToken}`,
    };

    console.log('🔍 Envoi Whapi direct:', { to: adminPhone, messageLength: message.length, url });

    const response = await fetch(url, {
      method: 'POST',
      headers: headers,
      body: JSON.stringify(body),
      mode: 'cors', // Essayer avec CORS
    });

    // Vérifier si la réponse est OK avant de parser JSON
    if (!response.ok) {
      const errorText = await response.text();
      console.error('❌ ERREUR WHAPI HTTP:', response.status, errorText);
      throw new Error(`HTTP ${response.status}: ${errorText}`);
    }

    let responseData;
    try {
      responseData = await response.json();
    } catch (parseError) {
      console.error('❌ Erreur parsing JSON:', parseError);
      // Si le parsing échoue mais le status est 200, considérer comme succès
      if (response.status >= 200 && response.status < 300) {
        console.log('✅ Réponse OK sans JSON valide (probable succès)');
        return true;
      }
      return false;
    }

    if (response.status >= 200 && response.status < 300) {
      // Vérifier si la réponse contient un statut d'échec
      if (responseData.status && 
          (responseData.status.toString().toLowerCase().includes('fail') || 
           responseData.status.toString().toLowerCase().includes('error'))) {
        console.warn('⚠️ Statut d\'échec détecté malgré code HTTP 200:', responseData.status);
        return false;
      }
      
      if (responseData.error) {
        console.error('❌ Erreur dans la réponse:', responseData.error);
        return false;
      }
      
      if (responseData.sent === false) {
        console.warn('⚠️ Message non envoyé pour', adminPhone);
        return false;
      }
      
      console.log('✅ Succès Whapi pour', adminPhone, responseData);
      return true;
    } else {
      console.error('❌ ERREUR WHAPI:', response.status, responseData);
      return false;
    }
  } catch (error) {
    // Gestion spécifique des erreurs CORS
    if (error.message && error.message.includes('CORS')) {
      console.error('❌ Erreur CORS détectée. Solution: Créer une Supabase Edge Function');
      console.error('💡 Voir le fichier supabase/functions/send-whatsapp-notification/index.ts');
    } else if (error.name === 'TypeError' && error.message.includes('Failed to fetch')) {
      console.error('❌ Erreur réseau ou CORS. Impossible de contacter l\'API Whapi');
      console.error('💡 Solution: Créer une Supabase Edge Function pour contourner CORS');
    } else {
      console.error('❌ Exception lors de l\'envoi Whapi:', error);
      console.error('📚 Détails:', error.message, error.stack);
    }
    return false;
  }
}

/**
 * Envoie une notification WhatsApp à l'administrateur après qu'un client ait soumis une commande
 */
export async function sendNotificationToAdmin({
  trackingNumber,
  pickupAddress,
  destinationAddress,
  packageType,
  deliveryType,
  totalCost,
  customerPhone,
  customerName = '',
  recipientName = '',
  recipientPhone = '',
  paymentMethod = '',
}) {
  // Vérifier si les notifications sont activées
  if (!ADMIN_CONFIG.enableWhatsAppNotifications) {
    console.warn('⚠️ Notifications WhatsApp désactivées');
    return false;
  }

  // Construire le message de notification
  const message = buildOrderMessage({
    trackingNumber,
    pickupAddress,
    destinationAddress,
    packageType,
    deliveryType,
    totalCost,
    customerPhone,
    customerName,
    recipientName,
    recipientPhone,
    paymentMethod,
  });

  // Récupérer la liste des numéros administrateurs
  const adminPhones = ADMIN_CONFIG.adminWhatsAppNumbers;
  
  if (adminPhones.length === 0) {
    console.warn('⚠️ Aucun numéro administrateur configuré');
    return false;
  }

  console.log('📨 ENVOI NOTIFICATIONS ADMINISTRATEUR');
  console.log('📱 Numéros destinataires:', adminPhones.length);

  let successCount = 0;

  // Envoyer à tous les administrateurs
  for (let i = 0; i < adminPhones.length; i++) {
    const adminPhone = adminPhones[i];
    const normalizedAdminPhone = normalizePhone(adminPhone);
    
    console.log(`📨 Envoi ${i + 1}/${adminPhones.length} vers: ${normalizedAdminPhone}`);

    // Si Whapi est activé, essayer d'envoyer via Whapi
    if (WHAPI_CONFIG.enableWhapi) {
      console.log('🔵 Tentative d\'envoi via Whapi API...');
      const success = await sendViaWhapi(normalizedAdminPhone, message);
      
      if (success) {
        console.log('✅ Notification envoyée via Whapi');
        successCount++;
      } else {
        console.warn('⚠️ Échec Whapi pour', normalizedAdminPhone);
      }
    }
  }

  console.log('📊 RÉSUMÉ ENVOI NOTIFICATIONS');
  console.log(`✅ Succès: ${successCount}/${adminPhones.length}`);

  return successCount > 0;
}

