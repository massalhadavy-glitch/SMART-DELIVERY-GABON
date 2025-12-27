# 📦 Guide de Génération AAB pour Google Play Console

## 🎯 Objectif
Générer un fichier Android App Bundle (AAB) pour le téléversement sur Google Play Console en mode test.

## 🚀 Méthode Rapide

### Option 1 : Script Batch (Windows)
Double-cliquez sur `build_aab_test.bat` ou exécutez dans le terminal :
```bash
build_aab_test.bat
```

### Option 2 : Script PowerShell (Windows)
Ouvrez PowerShell et exécutez :
```powershell
.\build_aab_test.ps1
```

### Option 3 : Commande Flutter Directe
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

## 📋 Prérequis

### 1. Vérifier la Configuration du Keystore
Le fichier `android/key.properties` doit exister et contenir :
```properties
storePassword=votre_mot_de_passe_store
keyPassword=votre_mot_de_passe_key
keyAlias=votre_alias
storeFile=chemin/vers/votre/keystore.jks
```

### 2. Vérifier que le Keystore Existe
Le fichier keystore (`.jks` ou `.keystore`) doit exister au chemin spécifié dans `key.properties`.

### 3. Vérifier Flutter
```bash
flutter doctor
```

## 📍 Emplacement du Fichier Généré

Une fois le build terminé, le fichier AAB se trouve à :
```
build\app\outputs\bundle\release\app-release.aab
```

## 📤 Téléversement sur Google Play Console

1. **Connectez-vous** à [Google Play Console](https://play.google.com/console)
2. **Sélectionnez** votre application
3. **Allez dans** :
   - **Production** (pour une version de production)
   - **Tests internes** (pour tester avec un groupe restreint)
   - **Tests fermés** (pour tester avec un groupe plus large)
   - **Tests ouverts** (pour tester publiquement)
4. **Cliquez** sur "Créer une nouvelle version"
5. **Téléversez** le fichier `app-release.aab`
6. **Remplissez** les notes de version (obligatoire)
7. **Enregistrez** et **soumettez** pour révision

## ⚠️ Notes Importantes

- **Version Code** : Assurez-vous que le `versionCode` dans `pubspec.yaml` est supérieur à la version précédente
- **Version Name** : Le `versionName` doit suivre le format de version (ex: 1.0.0)
- **Signature** : Le AAB doit être signé avec le même keystore que les versions précédentes
- **Taille** : Les AAB sont généralement plus petits que les APK car Google Play génère des APK optimisés par appareil

## 🔍 Vérification du Fichier

Pour vérifier que le fichier AAB a été généré correctement :
```bash
# Vérifier l'existence du fichier
dir build\app\outputs\bundle\release\app-release.aab

# Vérifier la taille (doit être > 0)
```

## 🐛 Résolution de Problèmes

### Erreur : "key.properties not found"
- Vérifiez que le fichier existe dans `android/key.properties`
- Vérifiez que le chemin du keystore dans `key.properties` est correct

### Erreur : "Keystore file not found"
- Vérifiez que le fichier keystore existe au chemin spécifié
- Utilisez un chemin relatif depuis le dossier `android/` ou un chemin absolu

### Erreur : "Wrong password"
- Vérifiez les mots de passe dans `key.properties`
- Assurez-vous qu'il n'y a pas d'espaces avant/après les valeurs

### Build échoue
- Exécutez `flutter clean` puis `flutter pub get`
- Vérifiez `flutter doctor` pour les problèmes d'environnement
- Vérifiez les logs d'erreur pour plus de détails

## 📝 Version Actuelle

Vérifiez la version dans `pubspec.yaml` :
```yaml
version: 1.0.0+1
```
- `1.0.0` = versionName (affichée aux utilisateurs)
- `+1` = versionCode (incrémenté à chaque publication)

## ✅ Checklist Avant Publication

- [ ] Version code incrémenté dans `pubspec.yaml`
- [ ] Fichier `android/key.properties` configuré
- [ ] Keystore existe et est accessible
- [ ] Tests effectués localement
- [ ] Notes de version préparées
- [ ] AAB généré avec succès
- [ ] Fichier AAB téléversé sur Google Play Console

---

**Bon build ! 🚀**

