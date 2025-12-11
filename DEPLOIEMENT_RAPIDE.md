# 🚀 Déploiement Rapide - Politique de Confidentialité

## 📋 Scripts Automatisés

Deux scripts ont été créés pour automatiser le déploiement :

### Option 1 : Script PowerShell (Recommandé)

**Fichier :** `deploy_politique_confidentialite.ps1`

**Utilisation :**
```powershell
.\deploy_politique_confidentialite.ps1
```

**Fonctionnalités :**
- ✅ Vérifie que vous êtes dans un repository Git
- ✅ Ajoute automatiquement les fichiers importants
- ✅ Crée un commit avec un message approprié
- ✅ Demande confirmation avant chaque étape
- ✅ Pousse les modifications sur GitHub
- ✅ Affiche les prochaines étapes

### Option 2 : Script Batch (Windows)

**Fichier :** `deploy_politique_confidentialite.bat`

**Utilisation :**
Double-cliquez sur le fichier `deploy_politique_confidentialite.bat`

Ou en ligne de commande :
```cmd
deploy_politique_confidentialite.bat
```

**Note :** Ce script appelle le script PowerShell, donc PowerShell doit être installé.

---

## 🎯 Ce que fait le script

### Fichiers ajoutés automatiquement :

1. `web/public/politique-confidentialite.html` - Fichier HTML de la politique
2. `web/vercel.json` - Configuration Vercel mise à jour
3. `VERIFICATION_DEPLOIEMENT_VERCEL.md` - Document de vérification
4. `VERIFICATION_POLITIQUE_CONFIDENTIALITE.md` - Document de vérification
5. `VERIFICATION_DEPLOIEMENT_GITHUB.md` - Document de vérification
6. `METADONNEES_PLAYSTORE.md` - Métadonnées avec URL corrigée
7. `GUIDE_PUBLICATION_PLAYSTORE.md` - Guide avec URL corrigée

### Étapes automatiques :

1. ✅ Vérification du repository Git
2. ✅ Vérification de l'état Git
3. ✅ Ajout des fichiers importants
4. ✅ Création du commit
5. ✅ Push vers GitHub

---

## 🚀 Utilisation Rapide

### Méthode 1 : Double-clic (Windows)

1. Double-cliquez sur `deploy_politique_confidentialite.bat`
2. Suivez les instructions à l'écran
3. Confirmez les étapes quand demandé

### Méthode 2 : Ligne de commande

**PowerShell :**
```powershell
cd C:\smart_delivery-gabon_full_app\smart_delivery_gabon_full_app
.\deploy_politique_confidentialite.ps1
```

**CMD :**
```cmd
cd C:\smart_delivery-gabon_full_app\smart_delivery_gabon_full_app
deploy_politique_confidentialite.bat
```

---

## ⚠️ Authentification GitHub

Si le script demande une authentification lors du push :

### Option A : Personal Access Token (Recommandé)

1. Allez sur GitHub > Settings > Developer settings > Personal access tokens > Tokens (classic)
2. Cliquez sur "Generate new token (classic)"
3. Donnez un nom : `Vercel Deployment`
4. Sélectionnez la permission : `repo`
5. Cliquez sur "Generate token"
6. **Copiez le token** (vous ne le verrez qu'une fois !)
7. Quand Git demande le mot de passe, utilisez ce token

### Option B : GitHub CLI

```bash
gh auth login
```

Puis relancez le script.

---

## ✅ Après le Déploiement

Une fois le script terminé avec succès :

### 1. Vérifier le déploiement Vercel

1. Connectez-vous au [Vercel Dashboard](https://vercel.com/dashboard)
2. Vérifiez que le dernier déploiement est **"Ready"** (vert)
3. Attendez 2-3 minutes si le déploiement est en cours

### 2. Tester l'URL

Ouvrez dans votre navigateur :
```
https://www.smartdeliverygabon.com/politique-confidentialite.html
```

Vérifiez que :
- ✅ La page s'affiche correctement
- ✅ Toutes les informations sont présentes
- ✅ Les dates sont correctes (18 novembre 2024)
- ✅ Les informations de contact sont complètes

### 3. Ajouter dans Google Play Console

1. Connectez-vous à [Google Play Console](https://play.google.com/console)
2. Sélectionnez votre application **Smart Delivery Gabon**
3. Allez dans **"Politique et programmes"** > **"Politique de confidentialité"**
4. Entrez l'URL : `https://www.smartdeliverygabon.com/politique-confidentialite.html`
5. Cliquez sur **"Enregistrer"**
6. Vérifiez que Google valide l'URL (pas d'erreur)

---

## 🐛 Résolution de Problèmes

### Erreur : "Ce dossier n'est pas un repository Git"

**Solution :** Exécutez le script depuis la racine du projet (où se trouve le dossier `.git`)

### Erreur : "authentication failed" lors du push

**Solution :** Utilisez un Personal Access Token GitHub (voir section Authentification ci-dessus)

### Erreur : "Aucun remote 'origin' configuré"

**Solution :** Configurez le remote avec :
```bash
git remote add origin https://github.com/massalhadavy-glitch/SMART-DELIVERY-GABON.git
```

### Erreur : "PowerShell n'est pas installé"

**Solution :** 
- Installez PowerShell depuis [Microsoft Store](https://aka.ms/powershell) ou
- Utilisez directement le script PowerShell avec :
```powershell
powershell.exe -ExecutionPolicy Bypass -File deploy_politique_confidentialite.ps1
```

### Erreur : "Le terminateur est manquant dans la chaîne" ou problèmes d'encodage

**Solution :** 
Si vous rencontrez des erreurs d'encodage avec les caractères accentués :
1. Ouvrez le script dans un éditeur qui supporte UTF-8 avec BOM (comme VS Code)
2. Sauvegardez le fichier avec l'encodage "UTF-8 with BOM"
3. Ou utilisez les commandes manuelles (voir section "Commandes Manuelles" ci-dessous)

### Le script s'arrête sans erreur

**Solution :** Vérifiez que vous avez bien répondu "O" ou "Y" aux questions de confirmation

---

## 📝 Commandes Manuelles (Alternative)

Si vous préférez faire manuellement :

```bash
# 1. Ajouter les fichiers
git add web/public/politique-confidentialite.html
git add web/vercel.json
git add VERIFICATION_DEPLOIEMENT_VERCEL.md
git add VERIFICATION_POLITIQUE_CONFIDENTIALITE.md
git add VERIFICATION_DEPLOIEMENT_GITHUB.md
git add METADONNEES_PLAYSTORE.md
git add GUIDE_PUBLICATION_PLAYSTORE.md

# 2. Commiter
git commit -m "Mise à jour politique de confidentialité et configuration Vercel pour déploiement"

# 3. Pousser
git push origin main
```

---

## 🔒 Sécurité

Le script :
- ✅ Ne modifie pas vos fichiers
- ✅ Demande confirmation avant chaque étape importante
- ✅ N'utilise pas `--force` pour éviter d'écraser des commits
- ✅ Affiche clairement ce qu'il va faire avant de le faire

---

## 📞 Support

Si vous rencontrez des problèmes :

- **Email :** smartdeliverygabon@gmail.com
- **Téléphone :** 077773627
- **Repository GitHub :** https://github.com/massalhadavy-glitch/SMART-DELIVERY-GABON

---

**Date de création :** 2024  
**Projet :** Smart Delivery Gabon  
**Scripts :** `deploy_politique_confidentialite.ps1` et `deploy_politique_confidentialite.bat`

