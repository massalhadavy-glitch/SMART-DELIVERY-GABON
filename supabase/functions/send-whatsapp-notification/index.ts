// Supabase Edge Function pour envoyer des notifications WhatsApp
// Contourne les problèmes CORS en faisant l'appel depuis le serveur

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const WHAPI_CONFIG = {
  baseUrl: 'https://gate.whapi.cloud',
  authToken: 'LHdq7epYqlNkN6riPV6FHmCqvj5J0Y47',
};

serve(async (req) => {
  // Gérer les requêtes CORS
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      },
    });
  }

  try {
    const { to, message } = await req.json();

    if (!to || !message) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: to, message' }),
        {
          status: 400,
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        }
      );
    }

    // Appeler l'API Whapi
    const url = `${WHAPI_CONFIG.baseUrl}/messages/text`;
    
    const body = {
      to: to,
      body: message,
    };

    const headers = {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${WHAPI_CONFIG.authToken}`,
    };

    console.log('🔍 Envoi Whapi:', { to, messageLength: message.length });

    const response = await fetch(url, {
      method: 'POST',
      headers: headers,
      body: JSON.stringify(body),
    });

    const responseData = await response.json();

    if (response.status >= 200 && response.status < 300) {
      // Vérifier si la réponse contient un statut d'échec
      if (responseData.status && 
          (responseData.status.toString().toLowerCase().includes('fail') || 
           responseData.status.toString().toLowerCase().includes('error'))) {
        console.warn('⚠️ Statut d\'échec détecté');
        return new Response(
          JSON.stringify({ success: false, error: 'Failed to send message', details: responseData }),
          {
            status: 200,
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            },
          }
        );
      }
      
      if (responseData.error) {
        console.error('❌ Erreur dans la réponse:', responseData.error);
        return new Response(
          JSON.stringify({ success: false, error: responseData.error }),
          {
            status: 200,
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            },
          }
        );
      }
      
      if (responseData.sent === false) {
        console.warn('⚠️ Message non envoyé');
        return new Response(
          JSON.stringify({ success: false, error: 'Message not sent', details: responseData }),
          {
            status: 200,
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            },
          }
        );
      }
      
      console.log('✅ Succès Whapi');
      return new Response(
        JSON.stringify({ success: true, data: responseData }),
        {
          status: 200,
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        }
      );
    } else {
      console.error('❌ ERREUR WHAPI:', response.status, responseData);
      return new Response(
        JSON.stringify({ success: false, error: 'API error', status: response.status, details: responseData }),
        {
          status: response.status,
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        }
      );
    }
  } catch (error) {
    console.error('❌ Exception:', error);
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      {
        status: 500,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    );
  }
});















