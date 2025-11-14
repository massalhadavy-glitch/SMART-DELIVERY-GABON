# 🎯 Déploiement Complet - Étape par Étape

## 📋 Situation actuelle
- ❌ Projet pas encore sur Git
- ❌ Pas encore sur GitHub
- ❌ Pas encore déployé sur Vercel

## ✅ Objectif
- ✅ Projet sur GitHub
- ✅ Déployé sur Vercel
- ✅ Accessible sur smartdeliverygabon.com

---

## 🚀 ÉTAPE 1 : Initialiser Git (5 minutes)

### Option A : Script automatique (Windows)
1. Double-cliquez sur `INITIALISER_GIT.bat`
2. Suivez les instructions

### Option B : Commandes manuelles
Ouvrez PowerShell dans votre dossier projet et exécutez :

```powershell
# Initialiser Git
git init

# Ajouter tous les fichiers
git add .

# Faire le premier commit
git commit -m "Initial commit - Smart Delivery Gabon"
```

✅ **Résultat** : Votre projet est maintenant un repository Git local

---

## 📦 ÉTAPE 2 : Créer un repository GitHub (3 minutes)

1. Allez sur [github.com](https://github.com) et connectez-vous
2. Cliquez sur **"+"** > **"New repository"**
3. Remplissez :
   - **Name** : `smart-delivery-gabon`
   - **Description** : "Application Smart Delivery Gabon"
   - **Visibility** : Public ou Private (votre choix)
   - ⚠️ **NE COCHEZ PAS** "Add README" ou "Add .gitignore"
4. Cliquez sur **"Create repository"**
5. **COPIEZ L'URL** du repository (ex: `https://github.com/votre-username/smart-delivery-gabon.git`)

✅ **Résultat** : Repository GitHub créé (vide pour l'instant)

---

## 🔗 ÉTAPE 3 : Pousser le code sur GitHub (2 minutes)

Dans PowerShell, exécutez (remplacez l'URL par la vôtre) :

```powershell
# Ajouter le remote GitHub
git remote add origin https://github.com/VOTRE-USERNAME/smart-delivery-gabon.git

# Renommer la branche en main
git branch -M main

# Pousser le code
git push -u origin main
```

**Note** : Si GitHub demande une authentification :
- Utilisez votre **username GitHub**
- Pour le mot de passe, utilisez un **Personal Access Token**
  - Créez-en un : GitHub > Settings > Developer settings > Personal access tokens > Generate new token
  - Cochez `repo` dans les permissions
  - Copiez le token et utilisez-le comme mot de passe

✅ **Résultat** : Votre code est maintenant sur GitHub !

---

## 🚀 ÉTAPE 4 : Déployer sur Vercel (5 minutes)

1. Allez sur [vercel.com](https://vercel.com)
2. Cliquez sur **"Sign Up"** > **"Continue with GitHub"**
3. Autorisez Vercel à accéder à GitHub
4. Cliquez sur **"Add New Project"**
5. Vous devriez maintenant voir votre repository `smart-delivery-gabon`
6. Cliquez sur **"Import"**

### Configuration importante :

**Root Directory :**
- Cliquez sur **"Edit"**
- Entrez : `web`
- (Cela indique que votre app React est dans le dossier `web`)

**Build Settings :**
- Framework Preset : `Create React App`
- Build Command : `npm run build` (par défaut)
- Output Directory : `build` (par défaut)

**Environment Variables :**
Cliquez sur **"Environment Variables"** et ajoutez :
```
REACT_APP_SUPABASE_URL = https://phrgdydqxhgfynhzeokq.supabase.co
REACT_APP_SUPABASE_ANON_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBocmdkeWRxeGhnZnluaHplb2txIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE1ODA0MTcsImV4cCI6MjA3NzE1NjQxN30.6dxOlrQQRVznxiTgL3x0LeezD-u5bftnTwEbcIjan3A
```

7. Cliquez sur **"Deploy"**
8. Attendez 2-3 minutes

✅ **Résultat** : Votre site est déployé sur Vercel (URL temporaire : `votre-projet.vercel.app`)

---

## 🌐 ÉTAPE 5 : Connecter votre domaine (10 minutes)

1. Dans Vercel, allez dans **Settings** > **Domains**
2. Dans le champ "Domain", entrez : `smartdeliverygabon.com`
3. Cliquez sur **"Add"**
4. Vercel vous donnera des instructions DNS

### Configuration DNS :

Allez dans votre registrar (où vous avez acheté le domaine) et ajoutez :

**Pour le domaine principal :**
- Type : `A`
- Name : `@` (ou laissez vide)
- Value : L'IP que Vercel vous donne (ex: `76.76.21.21`)

**Pour www :**
- Type : `CNAME`
- Name : `www`
- Value : `cname.vercel-dns.com` (ou ce que Vercel vous indique)

5. Attendez 5-10 minutes pour la propagation DNS
6. Vercel configurera automatiquement HTTPS

✅ **Résultat** : Votre site est accessible sur `https://smartdeliverygabon.com`

---

## ⚙️ ÉTAPE 6 : Configurer Supabase (3 minutes)

1. Allez sur [app.supabase.com](https://app.supabase.com)
2. Sélectionnez votre projet : `phrgdydqxhgfynhzeokq`
3. Allez dans **Settings** > **Authentication** > **URL Configuration**

**Site URL :**
```
https://smartdeliverygabon.com
```

**Redirect URLs :**
Copiez-collez toutes ces URLs (une par ligne) :
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

✅ **Résultat** : Supabase est configuré pour votre domaine

---

## ✅ Checklist finale

- [ ] Git initialisé localement
- [ ] Code commité
- [ ] Repository GitHub créé
- [ ] Code poussé sur GitHub
- [ ] Compte Vercel créé
- [ ] Projet déployé sur Vercel
- [ ] Root Directory = `web` configuré
- [ ] Variables d'environnement ajoutées
- [ ] Domaine `smartdeliverygabon.com` connecté
- [ ] DNS configuré
- [ ] HTTPS activé
- [ ] Supabase URLs configurées
- [ ] Site accessible et fonctionnel

---

## 🎉 Félicitations !

Votre application Smart Delivery Gabon est maintenant :
- ✅ En ligne sur `https://smartdeliverygabon.com`
- ✅ Avec déploiement automatique (chaque push sur GitHub = nouveau déploiement)
- ✅ Sécurisée avec HTTPS
- ✅ Optimisée et performante

---

## 📚 Guides détaillés

- **Initialisation Git** : `GUIDE_INITIALISATION_GIT.md`
- **Déploiement Vercel** : `GUIDE_DEPLOIEMENT_VERCEL.md`
- **URLs Supabase** : `URLS_SUPABASE_A_COPIER.md`

---

**Temps total estimé** : ~30 minutes
**Difficulté** : Facile à Moyenne

