# 🗺️ Guide de Configuration - Suivi des Motos avec Google Maps

## 📋 Vue d'ensemble

Ce guide vous explique comment configurer le système de suivi GPS des livreurs/motos avec Google Maps dans l'application Smart Delivery Gabon.

## ✅ Prérequis

1. Un compte Google Cloud Platform
2. Un projet Supabase configuré
3. Les dépendances Flutter installées

---

## 🔧 Étape 1 : Configuration Google Maps API

### 1.1 Créer un projet Google Cloud

1. Allez sur [Google Cloud Console](https://console.cloud.google.com/)
2. Créez un nouveau projet ou sélectionnez un projet existant
3. Notez le **Project ID**

### 1.2 Activer les APIs nécessaires

Activez les APIs suivantes dans votre projet :

- **Maps SDK for Android**
- **Maps SDK for iOS**
- **Geocoding API** (optionnel, pour les adresses)

**Comment activer :**
1. Allez dans **APIs & Services** > **Library**
2. Recherchez chaque API
3. Cliquez sur **Enable**

### 1.3 Créer une clé API

1. Allez dans **APIs & Services** > **Credentials**
2. Cliquez sur **Create Credentials** > **API Key**
3. Copiez la clé API générée
4. **IMPORTANT** : Restreignez la clé API pour la sécurité :
   - Cliquez sur la clé créée
   - Dans **Application restrictions**, sélectionnez :
     - **Android apps** pour Android
     - **iOS apps** pour iOS
   - Ajoutez les restrictions appropriées

---

## 📱 Étape 2 : Configuration Android

### 2.1 Ajouter la clé API dans AndroidManifest.xml

Ouvrez `android/app/src/main/AndroidManifest.xml` et ajoutez :

```xml
<manifest>
    <application>
        <!-- Votre clé API Google Maps -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="VOTRE_CLE_API_GOOGLE_MAPS"/>
    </application>
</manifest>
```

### 2.2 Vérifier les permissions

Assurez-vous que les permissions suivantes sont présentes :

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

---

## 🍎 Étape 3 : Configuration iOS

### 3.1 Ajouter la clé API dans AppDelegate.swift

Ouvrez `ios/Runner/AppDelegate.swift` et ajoutez :

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("VOTRE_CLE_API_GOOGLE_MAPS")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 3.2 Ajouter les permissions dans Info.plist

Ouvrez `ios/Runner/Info.plist` et ajoutez :

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Cette application a besoin de votre localisation pour suivre les livreurs en temps réel.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Cette application a besoin de votre localisation pour suivre les livreurs en temps réel.</string>
```

---

## 🗄️ Étape 4 : Créer la table drivers dans Supabase

### 4.1 Exécuter le script SQL

1. Allez dans votre projet Supabase
2. Ouvrez le **SQL Editor**
3. Copiez-collez le contenu du fichier `CREATE_TABLE_DRIVERS.sql`
4. Cliquez sur **Run**

### 4.2 Vérifier la création

Exécutez cette requête pour vérifier :

```sql
SELECT * FROM public.drivers;
```

---

## 📦 Étape 5 : Installer les dépendances Flutter

Exécutez dans le terminal :

```bash
flutter pub get
```

Les dépendances suivantes seront installées :
- `google_maps_flutter: ^2.5.0`
- `geolocator: ^12.0.0`

---

## 🚀 Étape 6 : Tester l'application

### 6.1 Ajouter un livreur de test

Dans Supabase SQL Editor, exécutez :

```sql
INSERT INTO public.drivers (name, phone, vehicle_number, latitude, longitude, is_active)
VALUES 
    ('Jean Moto', '+24177123456', 'MOTO-001', 0.3921, 9.4536, true),
    ('Pierre Livreur', '+24177234567', 'MOTO-002', 0.3921, 9.4536, true);
```

### 6.2 Lancer l'application

```bash
flutter run
```

### 6.3 Accéder au suivi

1. Connectez-vous en tant qu'admin
2. Allez dans le **Tableau de Bord Admin**
3. Cliquez sur **"Suivi des Motos"** dans les Actions Rapides

---

## 📝 Utilisation

### Pour les Admins

1. **Voir tous les livreurs actifs** : La carte affiche tous les livreurs en temps réel
2. **Cliquer sur un marqueur** : Affiche les informations du livreur
3. **Centrer sur un livreur** : Cliquez sur "Centrer sur la carte" dans les détails
4. **Actualiser** : Utilisez le bouton de rafraîchissement dans l'AppBar

### Pour les Livreurs (à implémenter)

Les livreurs peuvent mettre à jour leur position en utilisant :

```dart
final locationService = DriverLocationService();
await locationService.startLocationTracking(driverId);
```

---

## 🔒 Sécurité

### Restrictions de clé API

1. **Android** : Ajoutez le SHA-1 de votre keystore
2. **iOS** : Ajoutez le Bundle ID de votre application
3. **Limitez par IP** : Pour les applications web (si applicable)

### Permissions

- Les permissions de localisation sont demandées uniquement quand nécessaire
- Les positions sont stockées de manière sécurisée dans Supabase
- Seuls les admins peuvent voir tous les livreurs

---

## 🐛 Dépannage

### Problème : La carte ne s'affiche pas

**Solutions :**
1. Vérifiez que la clé API est correctement configurée
2. Vérifiez que les APIs sont activées dans Google Cloud
3. Vérifiez les restrictions de la clé API

### Problème : Erreur de permissions

**Solutions :**
1. Vérifiez que les permissions sont dans AndroidManifest.xml (Android)
2. Vérifiez que les descriptions sont dans Info.plist (iOS)
3. Autorisez les permissions dans les paramètres de l'appareil

### Problème : Aucun livreur n'apparaît

**Solutions :**
1. Vérifiez que la table `drivers` existe dans Supabase
2. Vérifiez que `is_active = true` pour les livreurs
3. Vérifiez les politiques RLS dans Supabase

---

## 📚 Ressources

- [Documentation Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)
- [Documentation Geolocator](https://pub.dev/packages/geolocator)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Supabase Documentation](https://supabase.com/docs)

---

## ✅ Checklist de Configuration

- [ ] Projet Google Cloud créé
- [ ] APIs Google Maps activées
- [ ] Clé API créée et restreinte
- [ ] Clé API ajoutée dans AndroidManifest.xml
- [ ] Clé API ajoutée dans AppDelegate.swift
- [ ] Permissions ajoutées (Android et iOS)
- [ ] Table `drivers` créée dans Supabase
- [ ] Dépendances Flutter installées
- [ ] Application testée avec succès

---

**Note :** N'oubliez pas de remplacer `VOTRE_CLE_API_GOOGLE_MAPS` par votre vraie clé API dans les fichiers de configuration !






