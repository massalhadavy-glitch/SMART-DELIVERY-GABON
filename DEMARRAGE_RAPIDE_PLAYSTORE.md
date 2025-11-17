# ⚡ Démarrage Rapide - Publication Play Store

## 🎯 Guide Express (30 minutes)

### Étape 1 : Créer le Keystore (5 min)

1. Double-cliquez sur `create_keystore.bat`
2. Suivez les instructions à l'écran
3. **⚠️ IMPORTANT :** Notez les mots de passe dans un gestionnaire de mots de passe
4. Sauvegardez le fichier `android/keystore/smart_delivery_gabon.jks` en sécurité

### Étape 2 : Configurer key.properties (2 min)

1. Copiez `android/key.properties.example` vers `android/key.properties`
2. Éditez `android/key.properties` avec vos mots de passe réels

```properties
storePassword=VOTRE_MOT_DE_PASSE_STORE
keyPassword=VOTRE_MOT_DE_PASSE_KEY
keyAlias=smart_delivery_key
storeFile=../keystore/smart_delivery_gabon.jks
```

### Étape 3 : Vérifier la configuration (1 min)

✅ `lib/config/supabase_config.dart` : `debugMode = false` (déjà fait)

### Étape 4 : Build de production (10 min)

1. Double-cliquez sur `build_release.bat`
2. Attendez la fin du build
3. Le fichier `.aab` sera dans : `build/app/outputs/bundle/release/app-release.aab`

### Étape 5 : Tester l'APK (5 min)

1. Le script vous proposera de créer un APK
2. Installez l'APK sur votre téléphone
3. Testez rapidement :
   - ✅ L'app démarre
   - ✅ Connexion fonctionne
   - ✅ Création de colis fonctionne

### Étape 6 : Préparer les ressources (variable)

- [ ] Icône 512x512 (déjà dans `assets/images/smart_delivery_logo.png`)
- [ ] Captures d'écran (minimum 2)
- [ ] Description courte (voir `METADONNEES_PLAYSTORE.md`)
- [ ] Description complète (voir `METADONNEES_PLAYSTORE.md`)
- [ ] Politique de confidentialité (créer une page web)

### Étape 7 : Publier sur Play Console (variable)

1. Allez sur [Google Play Console](https://play.google.com/console)
2. Créez une nouvelle application
3. Remplissez toutes les sections
4. Téléchargez le fichier `.aab`
5. Soumettez pour révision

---

## 📚 Documentation complète

Pour plus de détails, consultez :
- **`GUIDE_PUBLICATION_PLAYSTORE.md`** : Guide complet étape par étape
- **`METADONNEES_PLAYSTORE.md`** : Tous les textes pour le Play Store
- **`docs/PLAYSTORE_CHECKLIST.md`** : Checklist technique

---

## ✅ Checklist rapide

- [ ] Keystore créé
- [ ] key.properties configuré
- [ ] debugMode = false
- [ ] Build réussi (.aab généré)
- [ ] APK testé sur appareil
- [ ] Captures d'écran prêtes
- [ ] Métadonnées rédigées
- [ ] Politique de confidentialité créée
- [ ] Prêt à publier !

---

**Temps total estimé :** 30 minutes (sans les ressources)



