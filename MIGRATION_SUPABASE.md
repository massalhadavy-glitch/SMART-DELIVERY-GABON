# 🔄 Migration Firebase → Supabase

## ✅ Modifications effectuées

### 1. Nouveau service créé
- ✅ `lib/services/supabase_package_service.dart` - Service complet pour Supabase
  - Stream de tous les colis
  - Ajout de colis
  - Mise à jour de statut
  - Vérification admin
  - Recherche par numéro de suivi

### 2. Modèle Package modifié
- ✅ Supprimé `cloud_firestore` import
- ✅ Changé de `Timestamp` vers `DateTime`
- ✅ Support des colonnes snake_case de Supabase
- ✅ Conversion flexible (supporte camelCase et snake_case)

### 3. Provider mis à jour
- ✅ `PackageNotifier` utilise maintenant `SupabasePackageService`
- ✅ Ajouté méthode `getPackageByTrackingNumber()`

### 4. Pages corrigées
- ✅ `login_page.dart` - Supprimé imports Firebase Auth
- ✅ `send_package_page.dart` - Supprimé import cloud_firestore
- ✅ Utilisation de Supabase pour vérification admin

### 5. Fichiers Firebase supprimés
- ✅ `android/app/google-services.json`
- ✅ `firebase.json`
- ✅ `firebase.rules`
- ✅ `functions/` (entier dossier)
- ✅ `web/src/firebase.js`
- ✅ Plugin Google Services retiré de `android/app/build.gradle.kts`

## 📋 Structure base de données Supabase

### Table: `packages`
```sql
CREATE TABLE packages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tracking_number TEXT UNIQUE NOT NULL,
  sender_name TEXT NOT NULL,
  sender_phone TEXT NOT NULL,
  client_phone_number TEXT NOT NULL,
  recipient_name TEXT NOT NULL,
  recipient_phone TEXT NOT NULL,
  pickup_address TEXT NOT NULL,
  destination_address TEXT NOT NULL,
  package_type TEXT NOT NULL,
  delivery_type TEXT NOT NULL,
  status TEXT NOT NULL,
  cost DOUBLE PRECISION NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Table: `admins`
```sql
CREATE TABLE admins (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  role TEXT NOT NULL DEFAULT 'admin',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 🔧 Configuration requise

### 1. Dans `lib/main.dart`
Mettre à jour les credentials Supabase :
```dart
await Supabase.initialize(
  url: 'VOTRE_URL_SUPABASE',
  anonKey: 'VOTRE_ANON_KEY',
);
```

### 2. Dans Supabase Dashboard
1. Créer les tables `packages` et `admins`
2. Configurer les politiques RLS (Row Level Security)
3. Ajouter un admin dans la table `admins`

### 3. Exemple de politique RLS pour packages
```sql
-- Permettre lecture à tous les utilisateurs authentifiés
CREATE POLICY "Lecture packages"
  ON packages
  FOR SELECT
  USING (auth.role() = 'authenticated');

-- Permettre insertion aux utilisateurs authentifiés
CREATE POLICY "Insertion packages"
  ON packages
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Permettre mise à jour aux admins
CREATE POLICY "Mise à jour packages"
  ON packages
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM admins 
      WHERE admins.id = auth.uid()
    )
  );
```

### 4. Exemple de politique RLS pour admins
```sql
-- Seuls les admins peuvent lire la table admins
CREATE POLICY "Lecture admins"
  ON admins
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM admins 
      WHERE admins.id = auth.uid()
    )
  );
```

## 🚀 Prochaines étapes

1. ✅ Exécuter `flutter pub get` pour installer les dépendances
2. ✅ Configurer les credentials Supabase dans `main.dart`
3. ✅ Créer les tables dans Supabase
4. ✅ Configurer les politiques RLS
5. ✅ Tester l'authentification
6. ✅ Tester la création de colis
7. ✅ Tester le suivi de colis

## 📝 Notes importantes

- Le projet utilise maintenant **100% Supabase** (plus de Firebase)
- Les colonnes en snake_case sont utilisées pour l'insertion
- Le modèle Package supporte les deux formats pour compatibilité
- Les streams sont utilisés pour des mises à jour en temps réel
- L'authentification admin est vérifiée via la table `admins`

