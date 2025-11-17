# Configuration des Notifications WhatsApp pour le Web

## Problème CORS

Les navigateurs bloquent les requêtes directes vers l'API Whapi à cause des restrictions CORS (Cross-Origin Resource Sharing). 

## Solution : Supabase Edge Function

Nous utilisons une Supabase Edge Function pour contourner ce problème. La fonction fait l'appel API depuis le serveur, où il n'y a pas de restrictions CORS.

## Installation

### Option 1 : Utiliser la Supabase Edge Function (Recommandé)

1. **Déployer la fonction Supabase** :
```bash
cd supabase
supabase functions deploy send-whatsapp-notification
```

2. **Activer l'utilisation de la fonction** dans `web/src/services/notificationService.js` :
```javascript
const useEdgeFunction = true; // Déjà activé
```

### Option 2 : Utiliser directement l'API (peut échouer à cause de CORS)

Si vous préférez essayer directement (peut ne pas fonctionner selon la configuration CORS de Whapi) :

1. Dans `web/src/services/notificationService.js`, changez :
```javascript
const useEdgeFunction = false;
```

## Vérification

1. Ouvrez la console du navigateur (F12)
2. Créez une commande via la page web
3. Vérifiez les logs dans la console :
   - `📨 ENVOI NOTIFICATIONS ADMINISTRATEUR` - La fonction est appelée
   - `✅ Notification envoyée via Whapi` - Succès
   - `❌ Erreur CORS` - Problème CORS, utilisez l'Edge Function

## Dépannage

### Erreur CORS
Si vous voyez une erreur CORS dans la console :
- Activez `useEdgeFunction = true`
- Déployez la Supabase Edge Function

### Erreur "Function not found"
- Vérifiez que la fonction est déployée : `supabase functions list`
- Vérifiez que vous utilisez le bon projet Supabase

### Erreur d'authentification
- Vérifiez que le token Whapi est correct dans `supabase/functions/send-whatsapp-notification/index.ts`
- Vérifiez que le token n'a pas expiré

## Test manuel

Pour tester la fonction Supabase directement :

```bash
curl -X POST https://[votre-projet].supabase.co/functions/v1/send-whatsapp-notification \
  -H "Authorization: Bearer [votre-anon-key]" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "24177773627",
    "message": "Test message"
  }'
```






