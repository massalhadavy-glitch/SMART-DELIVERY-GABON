# 🔗 URLs de redirection Supabase - Configuration

## 📋 URLs à configurer dans Supabase Dashboard

Allez dans votre projet Supabase : **Settings** > **Authentication** > **URL Configuration**

### 🌐 URLs de redirection (Redirect URLs)

Ajoutez les URLs suivantes dans le champ **Redirect URLs** :

#### 🏠 Développement (Development)
```
http://localhost:3000
http://localhost:3000/**
http://localhost:3000/auth/callback
http://localhost:3000/#/auth/callback
http://127.0.0.1:3000
http://127.0.0.1:3000/**
http://127.0.0.1:3000/auth/callback
```

#### 🚀 Production (Production)
```
https://smartdeliverygabon.com
https://smartdeliverygabon.com/**
https://smartdeliverygabon.com/auth/callback
https://smartdeliverygabon.com/#/auth/callback
https://www.smartdeliverygabon.com
https://www.smartdeliverygabon.com/**
https://www.smartdeliverygabon.com/auth/callback
```

#### 📱 Application Flutter Web (si déployée)
Si vous déployez l'application Flutter en version web :
```
https://smartdeliverygabon.com/web
https://smartdeliverygabon.com/web/**
https://smartdeliverygabon.com/web/#/auth/callback
```

### 🔧 Site URL (URL principale)

Définissez l'URL principale de votre site :

#### Développement
```
http://localhost:3000
```

#### Production
```
https://smartdeliverygabon.com
```

### 📧 Email Templates - URLs de redirection

Pour les emails de confirmation et réinitialisation de mot de passe, utilisez :

#### Développement
```
http://localhost:3000/auth/callback
```

#### Production
```
https://smartdeliverygabon.com/auth/callback
```

---

## 📝 Instructions de configuration

### Étape 1 : Accéder aux paramètres
1. Connectez-vous à [Supabase Dashboard](https://app.supabase.com)
2. Sélectionnez votre projet : `phrgdydqxhgfynhzeokq`
3. Allez dans **Settings** (⚙️) > **Authentication**
4. Cliquez sur **URL Configuration**

### Étape 2 : Configurer les URLs

#### Site URL
- **Développement** : `http://localhost:3000`
- **Production** : `https://smartdeliverygabon.com`

#### Redirect URLs
Copiez-collez toutes les URLs listées ci-dessus dans le champ **Redirect URLs** (une par ligne).

### Étape 3 : Sauvegarder
Cliquez sur **Save** pour enregistrer les modifications.

---

## 🎯 URLs spécifiques par fonctionnalité

### Authentification email/password
- Confirmation d'email : `https://smartdeliverygabon.com/auth/callback?type=signup`
- Réinitialisation mot de passe : `https://smartdeliverygabon.com/auth/callback?type=recovery`
- Connexion : `https://smartdeliverygabon.com/auth/callback?type=login`

### OAuth (si vous l'ajoutez plus tard)
- Google : `https://smartdeliverygabon.com/auth/callback?provider=google`
- Facebook : `https://smartdeliverygabon.com/auth/callback?provider=facebook`
- Apple : `https://smartdeliverygabon.com/auth/callback?provider=apple`

---

## ⚠️ Notes importantes

1. **Wildcards** : Utilisez `/**` pour autoriser toutes les sous-routes
2. **HTTPS en production** : Toujours utiliser HTTPS en production
3. **Sécurité** : Ne partagez pas ces URLs publiquement si elles contiennent des tokens
4. **Test** : Testez les redirections après configuration
5. **Flutter Web** : Si vous utilisez Flutter Web, ajoutez aussi les URLs Flutter

---

## 🔍 Vérification

Après configuration, testez :
1. ✅ Connexion utilisateur
2. ✅ Confirmation d'email
3. ✅ Réinitialisation de mot de passe
4. ✅ Déconnexion et reconnexion

---

## 📞 Support

Si vous rencontrez des erreurs de redirection :
- Vérifiez que l'URL correspond exactement (sans slash final si nécessaire)
- Vérifiez que le protocole (http/https) est correct
- Vérifiez que le port est correct (3000 pour React, etc.)

---

**Date de création** : $(date)
**Projet** : Smart Delivery Gabon
**Supabase Project** : phrgdydqxhgfynhzeokq

