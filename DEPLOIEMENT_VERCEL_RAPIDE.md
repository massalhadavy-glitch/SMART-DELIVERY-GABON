# 🚀 Déploiement Rapide sur Vercel

## ✅ Prérequis vérifiés

- ✅ Code sur GitHub : https://github.com/massalhadavy-glitch/SMART-DELIVERY-GABON.git
- ✅ Application React dans le dossier `web`
- ✅ Configuration Vercel prête (`vercel.json`)

---

## 📋 Étapes de déploiement

### Étape 1 : Créer un compte Vercel (si pas déjà fait)

1. Allez sur [https://vercel.com](https://vercel.com)
2. Cliquez sur **"Sign Up"**
3. Choisissez **"Continue with GitHub"**
4. Autorisez Vercel à accéder à votre GitHub

---

### Étape 2 : Importer le projet

1. Dans le dashboard Vercel, cliquez sur **"Add New..."** > **"Project"**
2. Vous verrez la liste de vos repositories GitHub
3. **Trouvez** : `SMART-DELIVERY-GABON` (ou `massalhadavy-glitch/SMART-DELIVERY-GABON`)
4. Cliquez sur **"Import"**

---

### Étape 3 : Configurer le projet

#### Configuration importante :

**Framework Preset :**
- Sélectionnez : `Create React App`

**Root Directory :**
- Cliquez sur **"Edit"**
- Entrez : `web`
- ⚠️ **CRITIQUE** : Cela indique à Vercel que votre app React est dans le dossier `web`

**Build Command :**
- Laissez : `npm run build`

**Output Directory :**
- Laissez : `build`

**Install Command :**
- Laissez : `npm install`

---

### Étape 4 : Variables d'environnement (OBLIGATOIRE)

**Avant de déployer**, ajoutez ces variables :

1. Cliquez sur **"Environment Variables"**
2. Ajoutez ces 2 variables :

**Variable 1 :**
- **Name :** `REACT_APP_SUPABASE_URL`
- **Value :** `https://phrgdydqxhgfynhzeokq.supabase.co`
- **Environments :** ✅ Production, ✅ Preview, ✅ Development

**Variable 2 :**
- **Name :** `REACT_APP_SUPABASE_ANON_KEY`
- **Value :** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBocmdkeWRxeGhnZnluaHplb2txIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE1ODA0MTcsImV4cCI6MjA3NzE1NjQxN30.6dxOlrQQRVznxiTgL3x0LeezD-u5bftnTwEbcIjan3A`
- **Environments :** ✅ Production, ✅ Preview, ✅ Development

3. Cliquez sur **"Save"**

---

### Étape 5 : Déployer

1. Cliquez sur **"Deploy"**
2. Attendez 2-3 minutes
3. ✅ Votre site sera disponible sur une URL Vercel (ex: `smart-delivery-gabon.vercel.app`)

---

## 🌐 Étape 6 : Configurer le domaine ✅

✅ **Domaine configuré :** www.smartdeliverygabon.com

Le domaine a été configuré avec succès sur Vercel. Votre site est accessible à :
- https://www.smartdeliverygabon.com
- https://smartdeliverygabon.com (redirection automatique)

---

## ⚙️ Étape 7 : Mettre à jour Supabase

Une fois déployé, mettez à jour Supabase :

1. Allez sur [Supabase Dashboard](https://app.supabase.com)
2. Sélectionnez votre projet
3. Allez dans **Settings** > **Authentication** > **URL Configuration**

**Site URL :**
```
https://www.smartdeliverygabon.com
```

**Redirect URLs :**
Ajoutez toutes ces URLs :
```
http://localhost:3000
http://localhost:3000/**
http://localhost:3000/auth/callback
https://www.smartdeliverygabon.com
https://www.smartdeliverygabon.com/**
https://www.smartdeliverygabon.com/auth/callback
https://smartdeliverygabon.com
https://smartdeliverygabon.com/**
https://smartdeliverygabon.com/auth/callback
```

4. Cliquez sur **"Save"**

---

## ✅ Checklist de déploiement

- [ ] Compte Vercel créé
- [ ] Projet importé depuis GitHub
- [ ] Root Directory configuré : `web`
- [ ] Variables d'environnement ajoutées (2 variables)
- [ ] Déploiement lancé
- [ ] Site accessible sur URL Vercel
- [ ] Supabase URLs configurées
- [ ] Domaine personnalisé configuré (si applicable)

---

## 🆘 Résolution de problèmes

### Erreur : "Build failed"
- Vérifiez que Root Directory est bien `web`
- Vérifiez les variables d'environnement
- Consultez les logs de build dans Vercel

### Erreur : "Variables not found"
- Vérifiez que les variables commencent par `REACT_APP_`
- Vérifiez qu'elles sont activées pour Production

### Erreur : "404 on routes"
- Vérifiez que `vercel.json` contient les rewrites
- Vérifiez la configuration des routes

---

## 🎉 Félicitations !

Une fois déployé, votre application sera :
- ✅ En ligne et accessible
- ✅ Avec HTTPS automatique
- ✅ Avec déploiement automatique à chaque push sur GitHub

---

**Date :** 2024  
**Projet :** Smart Delivery Gabon  
**Plateforme :** Vercel
