# 🏗️ Étape : Build de Production

## ✅ Configuration terminée !

Vous avez maintenant :
- ✅ Keystore créé : `android/keystore/smart_delivery_gabon.jks`
- ✅ key.properties configuré avec vos mots de passe
- ✅ debugMode = false (production)

---

## 🚀 Build de production

### Option 1 : Utiliser le script (Recommandé)

**Double-cliquez sur :** `build_release.bat`

Le script va :
1. Nettoyer le projet
2. Installer les dépendances
3. Créer le fichier `.aab` pour le Play Store

### Option 2 : Commande manuelle

Dans PowerShell, à la racine du projet :

```powershell
flutter clean
flutter pub get
flutter build appbundle --release
```

---

## 📦 Fichier généré

Une fois le build terminé, vous trouverez le fichier :

```
build/app/outputs/bundle/release/app-release.aab
```

**C'est ce fichier que vous téléchargerez dans Google Play Console !**

---

## ⏱️ Temps estimé

Le build prend généralement **5-10 minutes** la première fois.

---

## ✅ Vérifications après le build

1. **Fichier créé** : Vérifiez que `app-release.aab` existe
2. **Taille** : Le fichier devrait faire entre 10-50 MB (selon votre app)
3. **Pas d'erreurs** : Le build doit se terminer sans erreur

---

## 🧪 Test avec APK (optionnel)

Pour tester l'application avant de publier, vous pouvez créer un APK :

```powershell
flutter build apk --release
```

Le fichier sera dans : `build/app/outputs/flutter-apk/app-release.apk`

Installez-le sur votre téléphone Android pour tester.

---

## 🆘 Si le build échoue

### Erreur : "Keystore not found"
- Vérifiez que `android/key.properties` existe
- Vérifiez le chemin dans `storeFile`

### Erreur : "Wrong password"
- Vérifiez les mots de passe dans `key.properties`
- Assurez-vous qu'ils correspondent à ceux du keystore

### Erreur : "Build failed"
- Vérifiez les logs pour plus de détails
- Essayez : `flutter clean` puis rebuild

---

## 🎯 Prochaine étape après le build

Une fois le `.aab` créé :
1. Préparez les captures d'écran
2. Rédigez les descriptions (voir `METADONNEES_PLAYSTORE.md`)
3. Créez la politique de confidentialité
4. Publiez dans Google Play Console

---

**Lancez le build maintenant ! 💪**


