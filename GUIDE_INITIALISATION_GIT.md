# 🔧 Guide : Initialiser Git et Connecter à GitHub

## 📋 Problème
Vercel affiche "No Git Repositories Found" car votre projet n'est pas encore sur GitHub.

## ✅ Solution : Initialiser Git et pousser sur GitHub

---

## 🚀 Étape 1 : Initialiser Git localement

### 1.1 Vérifier que Git est installé

Ouvrez PowerShell ou Terminal et tapez :
```bash
git --version
```

Si Git n'est pas installé, téléchargez-le : [https://git-scm.com/download/win](https://git-scm.com/download/win)

### 1.2 Initialiser le repository Git

Dans votre terminal, naviguez vers votre projet :
```powershell
cd C:\smart_delivery-gabon_full_app\smart_delivery_gabon_full_app
```

Initialisez Git :
```bash
git init
```

### 1.3 Vérifier le .gitignore

Assurez-vous qu'un fichier `.gitignore` existe. S'il n'existe pas, créez-en un (voir ci-dessous).

### 1.4 Ajouter tous les fichiers

```bash
git add .
```

### 1.5 Faire le premier commit

```bash
git commit -m "Initial commit - Smart Delivery Gabon"
```

---

## 📝 Étape 2 : Créer un repository sur GitHub

### 2.1 Créer un compte GitHub (si vous n'en avez pas)

1. Allez sur [https://github.com](https://github.com)
2. Cliquez sur **"Sign up"**
3. Créez votre compte (gratuit)

### 2.2 Créer un nouveau repository

1. Connectez-vous à GitHub
2. Cliquez sur le **"+"** en haut à droite > **"New repository"**
3. Remplissez les informations :
   - **Repository name** : `smart-delivery-gabon` (ou le nom que vous préférez)
   - **Description** : "Application Smart Delivery Gabon - Livraison de colis"
   - **Visibility** : 
     - ✅ **Public** (gratuit, visible par tous)
     - 🔒 **Private** (gratuit aussi, mais seulement vous pouvez voir)
   - ⚠️ **NE COCHEZ PAS** "Add a README file" (vous avez déjà des fichiers)
   - ⚠️ **NE COCHEZ PAS** "Add .gitignore" (vous en avez déjà un)
4. Cliquez sur **"Create repository"**

### 2.3 Copier l'URL du repository

GitHub vous donnera une URL comme :
```
https://github.com/votre-username/smart-delivery-gabon.git
```

**Copiez cette URL**, vous en aurez besoin à l'étape suivante.

---

## 🔗 Étape 3 : Connecter votre projet local à GitHub

### 3.1 Ajouter le remote GitHub

Dans votre terminal, exécutez (remplacez l'URL par la vôtre) :
```bash
git remote add origin https://github.com/votre-username/smart-delivery-gabon.git
```

### 3.2 Vérifier la branche principale

```bash
git branch -M main
```

### 3.3 Pousser le code sur GitHub

```bash
git push -u origin main
```

**Note** : GitHub vous demandera peut-être de vous authentifier :
- Si vous utilisez HTTPS, utilisez un **Personal Access Token** (voir ci-dessous)
- Si vous utilisez SSH, configurez d'abord vos clés SSH

---

## 🔐 Étape 4 : Authentification GitHub (si nécessaire)

### Option A : Personal Access Token (Recommandé pour débutants)

1. Allez sur GitHub > **Settings** > **Developer settings** > **Personal access tokens** > **Tokens (classic)**
2. Cliquez sur **"Generate new token"** > **"Generate new token (classic)"**
3. Donnez un nom : `Vercel Deployment`
4. Sélectionnez les permissions :
   - ✅ `repo` (accès complet aux repositories)
5. Cliquez sur **"Generate token"**
6. **COPIEZ LE TOKEN** (vous ne le verrez qu'une fois !)
7. Quand Git vous demande le mot de passe, utilisez ce token au lieu de votre mot de passe

### Option B : GitHub CLI (Plus simple)

Installez GitHub CLI :
```bash
# Téléchargez depuis : https://cli.github.com
```

Puis authentifiez-vous :
```bash
gh auth login
```

---

## ✅ Étape 5 : Vérifier que tout fonctionne

1. Allez sur votre repository GitHub
2. Vous devriez voir tous vos fichiers
3. ✅ Votre code est maintenant sur GitHub !

---

## 🚀 Étape 6 : Déployer sur Vercel

Maintenant que votre code est sur GitHub :

1. Allez sur [vercel.com](https://vercel.com)
2. Connectez-vous avec GitHub
3. Cliquez sur **"Add New Project"**
4. Vous devriez maintenant voir votre repository `smart-delivery-gabon`
5. Cliquez sur **"Import"**
6. Suivez le guide de déploiement : `GUIDE_DEPLOIEMENT_VERCEL.md`

---

## 📋 Checklist complète

- [ ] Git installé sur votre machine
- [ ] Repository Git initialisé (`git init`)
- [ ] Fichiers ajoutés (`git add .`)
- [ ] Premier commit fait (`git commit`)
- [ ] Compte GitHub créé
- [ ] Repository GitHub créé
- [ ] Remote ajouté (`git remote add origin`)
- [ ] Code poussé sur GitHub (`git push`)
- [ ] Repository visible sur GitHub
- [ ] Prêt pour Vercel !

---

## 🐛 Résolution de problèmes

### Erreur : "fatal: not a git repository"
**Solution** : Exécutez `git init` dans le dossier de votre projet

### Erreur : "remote origin already exists"
**Solution** : 
```bash
git remote remove origin
git remote add origin https://github.com/votre-username/smart-delivery-gabon.git
```

### Erreur : "authentication failed"
**Solution** : Utilisez un Personal Access Token au lieu de votre mot de passe

### Erreur : "refusing to merge unrelated histories"
**Solution** :
```bash
git pull origin main --allow-unrelated-histories
git push -u origin main
```

---

## 📞 Support

- **Documentation Git** : https://git-scm.com/doc
- **Documentation GitHub** : https://docs.github.com
- **GitHub Support** : https://support.github.com

---

**Prochaine étape** : Une fois le code sur GitHub, suivez `GUIDE_DEPLOIEMENT_VERCEL.md`

