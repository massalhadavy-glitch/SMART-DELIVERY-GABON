# Supabase Edge Function - Envoi de Notifications WhatsApp

Cette fonction permet d'envoyer des notifications WhatsApp via l'API Whapi en contournant les restrictions CORS du navigateur.

## Déploiement

### Prérequis

1. Installer Supabase CLI :
```bash
npm install -g supabase
```

2. Se connecter à Supabase :
```bash
supabase login
```

3. Lier le projet :
```bash
supabase link --project-ref [votre-project-ref]
```

### Déployer la fonction

```bash
supabase functions deploy send-whatsapp-notification
```

## Configuration

Le token Whapi est configuré directement dans le fichier `index.ts`. 

⚠️ **Sécurité** : En production, utilisez des secrets Supabase plutôt que de hardcoder le token.

Pour utiliser des secrets :
```bash
supabase secrets set WHAPI_TOKEN=LHdq7epYqlNkN6riPV6FHmCqvj5J0Y47
```

Puis dans `index.ts`, utilisez :
```typescript
const authToken = Deno.env.get('WHAPI_TOKEN') || 'LHdq7epYqlNkN6riPV6FHmCqvj5J0Y47';
```

## Test

Testez la fonction localement :
```bash
supabase functions serve send-whatsapp-notification
```

Puis testez avec curl :
```bash
curl -X POST http://localhost:54321/functions/v1/send-whatsapp-notification \
  -H "Authorization: Bearer [votre-anon-key]" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "24177773627",
    "message": "Test message"
  }'
```

## Utilisation depuis le frontend

La fonction est automatiquement appelée depuis `web/src/services/notificationService.js` lorsque `useEdgeFunction = true`.






