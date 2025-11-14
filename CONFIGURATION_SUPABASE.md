# ⚙️ Configuration Supabase

## 📋 Étapes de configuration

### 1. Créer un projet Supabase

1. Allez sur [https://supabase.com](https://supabase.com)
2. Créez un compte ou connectez-vous
3. Cliquez sur "New Project"
4. Remplissez les informations de votre projet
5. Attendez la création du projet (2-3 minutes)

### 2. Récupérer les credentials

Une fois le projet créé :

1. Allez dans **Settings** > **API**
2. Copiez les informations suivantes :
   - **Project URL** : `https://xxxxxxxxxxxxx.supabase.co`
   - **anon public key** : La clé commence par `eyJhbG...`

### 3. Configurer dans l'application

Modifiez le fichier `lib/config/supabase_config.dart` :

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://votre-projet.supabase.co';
  static const String supabaseAnonKey = 'votre_clé_anon';
  static const bool debugMode = true;
}
```

### 4. Créer les tables dans Supabase

Exécutez ces requêtes SQL dans le SQL Editor de Supabase :

#### Table `packages`

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

-- Créer un index sur tracking_number pour les recherches rapides
CREATE INDEX idx_tracking_number ON packages(tracking_number);

-- Créer un index sur client_phone_number pour filtrer par client
CREATE INDEX idx_client_phone ON packages(client_phone_number);
```

#### Table `admins`

```sql
CREATE TABLE admins (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  role TEXT NOT NULL DEFAULT 'admin',
  email TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 5. Configurer les politiques RLS (Row Level Security)

Activez RLS pour les tables :

```sql
-- Activer RLS sur la table packages
ALTER TABLE packages ENABLE ROW LEVEL SECURITY;

-- Activer RLS sur la table admins
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;
```

#### Politique de lecture pour packages

```sql
CREATE POLICY "Lecture packages"
  ON packages
  FOR SELECT
  USING (true); -- Permettre la lecture à tous (ou auth.role() = 'authenticated')
```

#### Politique d'insertion pour packages

```sql
CREATE POLICY "Insertion packages"
  ON packages
  FOR INSERT
  WITH CHECK (true); -- Permettre l'insertion à tous
```

#### Politique de mise à jour pour packages (admins uniquement)

```sql
CREATE POLICY "Mise à jour packages"
  ON packages
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM admins 
      WHERE admins.id = auth.uid()
    )
    OR true -- Temporairement, vous pouvez restreindre plus tard
  );
```

#### Politique pour la table admins

```sql
-- Permettre la lecture de la table admins pour vérifier les rôles
CREATE POLICY "Lecture admins"
  ON admins
  FOR SELECT
  USING (true); -- Vous pouvez restreindre plus tard
```

### 6. Créer un utilisateur admin

Dans Supabase Dashboard, allez dans **Authentication** > **Users** et créez un utilisateur avec email/password.

Ensuite, ajoutez-le dans la table admins via SQL :

```sql
INSERT INTO admins (id, email, role)
VALUES (
  'user_id_ici', -- L'UUID de l'utilisateur créé
  'admin@example.com',
  'admin'
);
```

### 7. Tester la connexion

Exécutez l'application :

```bash
flutter run
```

Vous devriez voir dans les logs :
```
✅ Supabase initialisé avec succès
```

Si vous voyez une erreur, vérifiez :
- Vos credentials dans `supabase_config.dart`
- Que les tables sont créées
- Que RLS est configuré correctement

## 🔒 Sécurité

⚠️ **Important** : Les politiques actuelles sont très permissives pour faciliter le développement. Pour la production :

1. Restreignez les politiques RLS
2. Authentifiez les utilisateurs avant d'autoriser l'insertion
3. Limitez la mise à jour aux admins uniquement
4. Activez les audits de sécurité dans Supabase

## 📚 Ressources

- [Documentation Supabase](https://supabase.com/docs)
- [Guide Flutter + Supabase](https://supabase.com/docs/guides/flutter)
- [Guide RLS](https://supabase.com/docs/guides/auth/row-level-security)

## ✅ Checklist de configuration

- [ ] Projet Supabase créé
- [ ] Credentials ajoutés dans `supabase_config.dart`
- [ ] Table `packages` créée
- [ ] Table `admins` créée
- [ ] Index créés sur `tracking_number` et `client_phone_number`
- [ ] RLS activé sur les deux tables
- [ ] Politiques RLS configurées
- [ ] Utilisateur admin créé
- [ ] Application testée avec succès

