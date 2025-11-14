# ✅ Checklist de Publication sur le Play Store

## 📋 Vérification Pré-Publication

### ✅ 1. Configuration Android

#### Application ID
- ✅ **Application ID unique**: `com.smartdeliverygabon.app`
- ✅ **Namespace**: `com.smartdeliverygabon.app`
- ⚠️ **MainActivity package**: Nécessite mise à jour (actuellement `com.example.smart_delivery_gabon_full_app`)

#### Version
- ✅ **Version Name**: 1.0.0 (défini dans `pubspec.yaml`)
- ✅ **Version Code**: 1 (défini dans `pubspec.yaml`)
- ⚠️ **À faire**: Incrémenter le versionCode à chaque nouvelle version

#### Signing Configuration
- ✅ **Configuration de signature**: Configurée dans `build.gradle.kts`
- ⚠️ **Keystore**: À créer (voir instructions ci-dessous)
- ⚠️ **key.properties**: À créer depuis `key.properties.example`

### ✅ 2. AndroidManifest.xml

- ✅ **Nom de l'application**: "Smart Delivery Gabon"
- ✅ **Permissions**: 
  - INTERNET ✅
  - ACCESS_NETWORK_STATE ✅
  - READ_PHONE_STATE ✅
  - CALL_PHONE ✅
- ✅ **usesCleartextTraffic**: false (sécurisé)
- ✅ **Queries**: Configurés pour WhatsApp

### ✅ 3. Build Configuration

- ✅ **MinifyEnabled**: true
- ✅ **ShrinkResources**: true
- ✅ **ProGuard Rules**: Configuré
- ✅ **MultiDex**: Activé
- ✅ **Target SDK**: À jour via Flutter

### ✅ 4. Fichiers Sensibles

- ✅ **.gitignore**: Configuré pour exclure:
  - `key.properties`
  - `*.jks`
  - `*.keystore`
  - Configurations Supabase et Admin

### ⚠️ 5. Actions Requises AVANT Publication

#### A. Créer le Keystore

```bash
# Créer le dossier keystore
mkdir -p android/keystore

# Générer le keystore
keytool -genkey -v -keystore android/keystore/smart_delivery_gabon.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias smart_delivery_key \
  -storepass VOTRE_MOT_DE_PASSE_STORE \
  -keypass VOTRE_MOT_DE_PASSE_KEY
```

**⚠️ IMPORTANT**: 
- Conservez le keystore en sécurité
- Notez les mots de passe dans un gestionnaire de mots de passe
- Ne perdez jamais le keystore, vous ne pourrez plus mettre à jour l'app sur le Play Store

#### B. Créer key.properties

```bash
# Copier le fichier exemple
cp android/key.properties.example android/key.properties

# Éditer avec vos valeurs réelles
```

Remplir avec:
```
storePassword=votre_mot_de_passe_store
keyPassword=votre_mot_de_passe_key
keyAlias=smart_delivery_key
storeFile=../keystore/smart_delivery_gabon.jks
```

#### C. Mettre à jour MainActivity.kt

Le package doit correspondre au namespace. Actuellement:
- Namespace: `com.smartdeliverygabon.app`
- Package MainActivity: `com.example.smart_delivery_gabon_full_app` ❌

**Action**: Déplacer ou renommer MainActivity.kt

#### D. Configurations de Production

1. **Supabase Config**: Vérifier que `lib/config/supabase_config.dart` utilise les credentials de production
2. **Debug Mode**: Désactiver `debugMode: false` dans SupabaseConfig
3. **Admin Config**: Vérifier les configurations admin

### ✅ 6. Tests Avant Publication

- [ ] Test de build release: `flutter build appbundle --release`
- [ ] Test sur différents appareils Android
- [ ] Test de toutes les fonctionnalités:
  - [ ] Création de colis
  - [ ] Suivi de colis
  - [ ] Connexion utilisateur
  - [ ] Connexion admin
  - [ ] Notifications WhatsApp
  - [ ] Appels téléphoniques
- [ ] Test de performance (APK/AAB size)
- [ ] Test de sécurité (pas de données sensibles dans le code)

### ✅ 7. Informations Play Store

#### Métadonnées Requises

- [ ] **Nom de l'application**: Smart Delivery Gabon
- [ ] **Description courte**: (max 80 caractères)
- [ ] **Description complète**: (max 4000 caractères)
- [ ] **Captures d'écran**: 
  - Au moins 2 (téléphone)
  - Au moins 1 (tablette 7")
  - Au moins 1 (tablette 10")
- [ ] **Icône haute résolution**: 512x512 px
- [ ] **Bannière de fonctionnalité**: 1024x500 px (optionnel)
- [ ] **Graphique promotionnel**: 180x120 px (optionnel)

#### Catégorie et Classification

- [ ] **Catégorie**: Livraison / Transport / Logistique
- [ ] **Classification de contenu**: Tous publics
- [ ] **Pays cibles**: Gabon (et autres si applicable)

#### Confidentialité

- [ ] **Politique de confidentialité**: URL requise
- [ ] **Permissions**: Justifier chaque permission:
  - INTERNET: Connexion aux services Supabase
  - ACCESS_NETWORK_STATE: Vérifier la connectivité
  - READ_PHONE_STATE: Authentification par téléphone
  - CALL_PHONE: Appeler depuis l'application

### ✅ 8. Checklist Finale

- [ ] Keystore créé et sauvegardé
- [ ] key.properties configuré
- [ ] MainActivity.kt package corrigé
- [ ] Build release testé avec succès
- [ ] Tous les tests passent
- [ ] APK/AAB généré sans erreurs
- [ ] Métadonnées Play Store préparées
- [ ] Politique de confidentialité rédigée
- [ ] Credentials Supabase de production configurés
- [ ] Debug mode désactivé

### 📝 Commandes Utiles

```bash
# Build App Bundle (recommandé pour Play Store)
flutter build appbundle --release

# Build APK (pour tests)
flutter build apk --release

# Vérifier la taille de l'APK
flutter build apk --release --analyze-size

# Vérifier les permissions
flutter pub run permission_handler:check_permissions
```

### 🔐 Sécurité

- ✅ Fichiers sensibles dans .gitignore
- ⚠️ Vérifier qu'aucune clé API n'est hardcodée
- ⚠️ Utiliser des variables d'environnement pour les secrets
- ⚠️ ProGuard activé pour l'obfuscation

### 📚 Ressources

- [Documentation Play Console](https://support.google.com/googleplay/android-developer)
- [Flutter App Publishing](https://docs.flutter.dev/deployment/android)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)







