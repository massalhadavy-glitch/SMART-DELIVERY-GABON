# ⚡ Déploiement Vercel - Guide Rapide

## 🎯 Étapes en 5 minutes

### 1️⃣ Préparer le code
```bash
# Vérifier que le build fonctionne
cd web
npm install
npm run build
```

### 2️⃣ Créer un compte Vercel
- Allez sur [vercel.com](https://vercel.com)
- Connectez-vous avec GitHub

### 3️⃣ Importer le projet
1. Cliquez sur **"Add New Project"**
2. Sélectionnez votre repository
3. **IMPORTANT** : Configurez le **Root Directory** = `web`
4. Ajoutez les variables d'environnement :
   ```
   REACT_APP_SUPABASE_URL = https://phrgdydqxhgfynhzeokq.supabase.co
   REACT_APP_SUPABASE_ANON_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBocmdkeWRxeGhnZnluaHplb2txIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE1ODA0MTcsImV4cCI6MjA3NzE1NjQxN30.6dxOlrQQRVznxiTgL3x0LeezD-u5bftnTwEbcIjan3A
   ```
5. Cliquez sur **"Deploy"**

### 4️⃣ Ajouter le domaine
1. Settings > Domains
2. Ajoutez : `smartdeliverygabon.com`
3. Configurez les DNS selon les instructions Vercel

### 5️⃣ Configurer Supabase
- Allez dans Supabase > Settings > Authentication > URL Configuration
- Ajoutez : `https://smartdeliverygabon.com` et toutes les URLs de redirection
- Voir `URLS_SUPABASE_A_COPIER.md` pour la liste complète

---

## ✅ C'est tout !

Votre site sera en ligne sur `https://smartdeliverygabon.com`

Pour le guide complet, voir : `GUIDE_DEPLOIEMENT_VERCEL.md`

