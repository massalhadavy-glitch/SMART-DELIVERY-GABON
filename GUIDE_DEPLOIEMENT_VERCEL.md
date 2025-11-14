# 🚀 Guide Complet - Déploiement sur Vercel

## 📋 Prérequis

- ✅ Compte GitHub (gratuit)
- ✅ Votre code doit être sur GitHub
- ✅ Compte Vercel (gratuit)
- ✅ Domaine `smartdeliverygabon.com` configuré

---

## 📝 Étape 1 : Préparer votre code pour la production

### 1.1 Créer un fichier `.env.example` (optionnel mais recommandé)

Créez `web/.env.example` :
```env
REACT_APP_SUPABASE_URL=https://phrgdydqxhgfynhzeokq.supabase.co
REACT_APP_SUPABASE_ANON_KEY=votre_cle_anon
```

### 1.2 Vérifier que votre build fonctionne localement

```bash
cd web
npm install
npm run build
```

Si le build fonctionne, vous êtes prêt ! ✅

---

## 🔐 Étape 2 : Créer un compte Vercel

1. Allez sur [https://vercel.com](https://vercel.com)
2. Cliquez sur **"Sign Up"**
3. Choisissez **"Continue with GitHub"** (recommandé)
4. Autorisez Vercel à accéder à votre GitHub

---

## 📦 Étape 3 : Déployer votre projet

### 3.1 Importer votre projet

1. Dans le dashboard Vercel, cliquez sur **"Add New..."** > **"Project"**
2. Vous verrez la liste de vos repositories GitHub
3. **Trouvez** votre repository `smart_delivery_gabon_full_app`
4. Cliquez sur **"Import"**

### 3.2 Configurer le projet

Vercel détectera automatiquement que c'est un projet React, mais vérifiez ces paramètres :

#### Configuration du projet :

**Framework Preset :**
- Sélectionnez : `Create React App`

**Root Directory :**
- Cliquez sur **"Edit"**
- Entrez : `web`
- (Cela indique à Vercel que votre app React est dans le dossier `web`)

**Build Command :**
- Laissez par défaut : `npm run build`
- Ou vérifiez que c'est bien : `npm run build`

**Output Directory :**
- Laissez par défaut : `build`
- (C'est le dossier créé par `react-scripts build`)

**Install Command :**
- Laissez par défaut : `npm install`

### 3.3 Variables d'environnement (IMPORTANT)

Avant de déployer, ajoutez vos variables d'environnement :

1. Cliquez sur **"Environment Variables"**
2. Ajoutez ces variables :

```
REACT_APP_SUPABASE_URL = https://phrgdydqxhgfynhzeokq.supabase.co
REACT_APP_SUPABASE_ANON_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBocmdkeWRxeGhnZnluaHplb2txIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE1ODA0MTcsImV4cCI6MjA3NzE1NjQxN30.6dxOlrQQRVznxiTgL3x0LeezD-u5bftnTwEbcIjan3A
```

3. Sélectionnez les environnements : **Production**, **Preview**, **Development**
4. Cliquez sur **"Save"**

### 3.4 Lancer le déploiement

1. Cliquez sur **"Deploy"**
2. Attendez 2-3 minutes que Vercel build et déploie votre application
3. ✅ Votre site sera disponible sur une URL Vercel (ex: `votre-projet.vercel.app`)

---

## 🌐 Étape 4 : Configurer votre domaine personnalisé

### 4.1 Ajouter votre domaine dans Vercel

1. Dans votre projet Vercel, allez dans **"Settings"** > **"Domains"**
2. Dans le champ "Domain", entrez : `smartdeliverygabon.com`
3. Cliquez sur **"Add"**
4. Vercel vous donnera des instructions DNS

### 4.2 Configurer les DNS

Vercel vous donnera des enregistrements DNS à ajouter. Généralement :

#### Option A : Configuration avec A Record (Recommandé)

Ajoutez ces enregistrements dans votre registrar (où vous avez acheté le domaine) :

**Pour le domaine principal :**
- Type : `A`
- Name : `@` (ou laissez vide)
- Value : `76.76.21.21` (IP de Vercel - vérifiez dans Vercel)

**Pour www :**
- Type : `CNAME`
- Name : `www`
- Value : `cname.vercel-dns.com` (vérifiez dans Vercel)

#### Option B : Configuration avec CNAME (Plus simple)

Vercel peut aussi utiliser uniquement des CNAME :
- Type : `CNAME`
- Name : `@` (ou utilisez un sous-domaine)
- Value : `cname.vercel-dns.com`

### 4.3 Vérifier la configuration

1. Attendez 5-10 minutes pour la propagation DNS
2. Dans Vercel, cliquez sur **"Refresh"** dans la section Domains
3. Vercel configurera automatiquement le certificat SSL (HTTPS)
4. ✅ Votre site sera accessible sur `https://smartdeliverygabon.com`

---

## ⚙️ Étape 5 : Mettre à jour Supabase

Maintenant que votre site est en ligne, configurez Supabase :

1. Allez sur [Supabase Dashboard](https://app.supabase.com)
2. Sélectionnez votre projet : `phrgdydqxhgfynhzeokq`
3. Allez dans **Settings** > **Authentication** > **URL Configuration**

### Site URL :
```
https://smartdeliverygabon.com
```

### Redirect URLs :
Copiez-collez toutes ces URLs (voir `URLS_SUPABASE_A_COPIER.md` pour la liste complète) :
```
http://localhost:3000
http://localhost:3000/**
http://localhost:3000/auth/callback
https://smartdeliverygabon.com
https://smartdeliverygabon.com/**
https://smartdeliverygabon.com/auth/callback
https://www.smartdeliverygabon.com
https://www.smartdeliverygabon.com/**
https://www.smartdeliverygabon.com/auth/callback
```

4. Cliquez sur **"Save"**

---

## 🔄 Étape 6 : Déploiements automatiques (CI/CD)

Vercel configure automatiquement le déploiement continu :

- ✅ **Chaque push sur `main`** → Déploiement en production
- ✅ **Chaque pull request** → Déploiement de prévisualisation
- ✅ **Build automatique** à chaque changement

### Comment ça marche :

1. Vous poussez du code sur GitHub
2. Vercel détecte automatiquement le changement
3. Vercel build et déploie automatiquement
4. Votre site est mis à jour en quelques minutes

---

## 🛠️ Étape 7 : Optimiser votre configuration (Optionnel)

### 7.1 Créer un fichier `vercel.json` (Optionnel)

Créez `web/vercel.json` pour des configurations avancées :

```json
{
  "buildCommand": "npm run build",
  "outputDirectory": "build",
  "devCommand": "npm start",
  "installCommand": "npm install",
  "framework": "create-react-app",
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```

### 7.2 Mettre à jour votre config Supabase pour utiliser les variables d'environnement

Modifiez `web/src/config/supabase.js` :

```javascript
// Configuration Supabase pour Smart Delivery Gabon Web
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.REACT_APP_SUPABASE_URL || 'https://phrgdydqxhgfynhzeokq.supabase.co';
const supabaseAnonKey = process.env.REACT_APP_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBocmdkeWRxeGhnZnluaHplb2txIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE1ODA0MTcsImV4cCI6MjA3NzE1NjQxN30.6dxOlrQQRVznxiTgL3x0LeezD-u5bftnTwEbcIjan3A';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
```

Cela permet d'utiliser les variables d'environnement en production tout en gardant des valeurs par défaut pour le développement.

---

## ✅ Checklist de déploiement

- [ ] Code poussé sur GitHub
- [ ] Compte Vercel créé
- [ ] Projet importé dans Vercel
- [ ] Root Directory configuré : `web`
- [ ] Variables d'environnement ajoutées
- [ ] Premier déploiement réussi
- [ ] Domaine `smartdeliverygabon.com` ajouté
- [ ] DNS configuré dans le registrar
- [ ] SSL/HTTPS activé automatiquement
- [ ] Supabase URLs configurées
- [ ] Site accessible sur `https://smartdeliverygabon.com`
- [ ] Tests de connexion fonctionnels
- [ ] Tests d'authentification fonctionnels

---

## 🐛 Résolution de problèmes

### Problème : Build échoue

**Solution :**
1. Vérifiez les logs de build dans Vercel
2. Testez le build localement : `cd web && npm run build`
3. Vérifiez que toutes les dépendances sont dans `package.json`

### Problème : Variables d'environnement non trouvées

**Solution :**
1. Vérifiez que les variables commencent par `REACT_APP_`
2. Vérifiez qu'elles sont ajoutées dans Vercel > Settings > Environment Variables
3. Redéployez après avoir ajouté les variables

### Problème : Domaine ne fonctionne pas

**Solution :**
1. Vérifiez que les DNS sont correctement configurés (attendez 24-48h max)
2. Utilisez un outil comme [whatsmydns.net](https://www.whatsmydns.net) pour vérifier
3. Vérifiez dans Vercel > Settings > Domains que le domaine est "Valid"

### Problème : Erreurs CORS dans Supabase

**Solution :**
1. Vérifiez que `https://smartdeliverygabon.com` est dans les URLs autorisées de Supabase
2. Vérifiez les Redirect URLs dans Supabase

### Problème : Routes ne fonctionnent pas (404)

**Solution :**
1. Créez un fichier `vercel.json` avec les rewrites (voir Étape 7.1)
2. Vercel doit rediriger toutes les routes vers `index.html` pour React Router

---

## 📊 Monitoring et Analytics

Vercel offre gratuitement :
- ✅ Analytics de performance
- ✅ Logs de déploiement
- ✅ Métriques de build
- ✅ Alertes par email

Accédez-y dans votre dashboard Vercel > Analytics

---

## 🔒 Sécurité

### Bonnes pratiques :

1. ✅ **Ne commitez jamais** vos clés API dans le code
2. ✅ **Utilisez toujours** les variables d'environnement
3. ✅ **HTTPS** est automatique avec Vercel
4. ✅ **Backup** régulier de votre code sur GitHub

---

## 📞 Support

- **Documentation Vercel** : https://vercel.com/docs
- **Support Vercel** : support@vercel.com
- **Communauté** : https://github.com/vercel/vercel/discussions

---

## 🎉 Félicitations !

Une fois toutes ces étapes complétées, votre application Smart Delivery Gabon sera :
- ✅ En ligne sur `https://smartdeliverygabon.com`
- ✅ Avec HTTPS automatique
- ✅ Avec déploiement automatique
- ✅ Optimisée et performante

---

**Date de création** : 2024
**Projet** : Smart Delivery Gabon
**Domaine** : smartdeliverygabon.com
**Plateforme** : Vercel

