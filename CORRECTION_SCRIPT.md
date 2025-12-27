# 🔧 Correction du Script de Déploiement

## ⚠️ Problème d'Encodage

Si vous rencontrez l'erreur :
```
Le terminateur " est manquant dans la chaîne
```

C'est un problème d'encodage du fichier PowerShell.

## ✅ Solutions

### Solution 1 : Sauvegarder avec UTF-8 BOM

1. Ouvrez `deploy_politique_confidentialite.ps1` dans VS Code
2. Cliquez sur l'encodage en bas à droite (probablement "UTF-8")
3. Sélectionnez "Save with Encoding"
4. Choisissez "UTF-8 with BOM"
5. Sauvegardez

### Solution 2 : Utiliser les commandes manuelles

Si le script ne fonctionne toujours pas, utilisez ces commandes manuelles :

```powershell
# 1. Ajouter les fichiers
git add web/public/politique-confidentialite.html
git add web/vercel.json
git add VERIFICATION_DEPLOIEMENT_VERCEL.md
git add VERIFICATION_POLITIQUE_CONFIDENTIALITE.md
git add VERIFICATION_DEPLOIEMENT_GITHUB.md
git add METADONNEES_PLAYSTORE.md
git add GUIDE_PUBLICATION_PLAYSTORE.md

# 2. Commiter
git commit -m "Mise a jour politique de confidentialite et configuration Vercel pour deploiement"

# 3. Pousser
git push origin main
```

### Solution 3 : Utiliser Git Bash

Si PowerShell pose problème, utilisez Git Bash :

```bash
# Dans Git Bash
./deploy_politique_confidentialite.ps1
```

Ou utilisez directement les commandes Git :

```bash
git add web/public/politique-confidentialite.html web/vercel.json VERIFICATION_*.md METADONNEES_PLAYSTORE.md GUIDE_PUBLICATION_PLAYSTORE.md
git commit -m "Mise a jour politique de confidentialite"
git push origin main
```

---

**Note :** Le script fonctionne correctement, mais l'encodage du fichier peut causer des problèmes selon l'éditeur utilisé. Les commandes manuelles sont toujours une alternative fiable.










