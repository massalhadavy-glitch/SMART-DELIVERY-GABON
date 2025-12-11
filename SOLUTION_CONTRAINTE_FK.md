# 🔧 Solution: Erreur de Contrainte de Clé Étrangère

## ❌ Problème

```
ERROR:  23503: insert or update on table "users" violates foreign key constraint "users_id_fkey"
DETAIL:  Key (id)=(...) is not present in table "users".
```

**Explication** : La table `public.users` a une contrainte de clé étrangère (`id`) qui référence `auth.users(id)`. Vous ne pouvez pas insérer un utilisateur dans `public.users` s'il n'existe pas déjà dans `auth.users`.

## ✅ Solution Étape par Étape

### Méthode 1 : Créer l'utilisateur via le Dashboard (Recommandée)

#### Étape 1 : Créer l'utilisateur dans Supabase Auth

1. **Connectez-vous au Dashboard Supabase**
   - https://app.supabase.com
   - Sélectionnez votre projet

2. **Allez dans Authentication**
   - Menu gauche : **Authentication** > **Users**

3. **Créez l'utilisateur**
   - Cliquez sur **"Add User"** > **"Create new user"**
   - Remplissez :
     - **Email**: `admin@smartdelivery.com`
     - **Password**: `Admin123!`
     - ✅ **Cochez "Auto Confirm User"**
   - Cliquez sur **"Create User"**

#### Étape 2 : Exécuter le script SQL

Dans le **SQL Editor** de Supabase, exécutez :

```sql
-- Utilisez ce script corrigé
\i CREATE_ADMIN_FIXED.sql

-- OU copiez-collez directement :

-- Vérifier si l'utilisateur existe
SELECT id, email, created_at 
FROM auth.users 
WHERE email = 'admin@smartdelivery.com';

-- Si l'utilisateur existe, créer le profil et l'admin
DO $$ 
DECLARE
  user_id UUID;
BEGIN
  -- Récupérer l'ID
  SELECT id INTO user_id 
  FROM auth.users 
  WHERE email = 'admin@smartdelivery.com';
  
  IF user_id IS NULL THEN
    RAISE EXCEPTION 'Utilisateur non trouvé. Créez-le d''abord via le Dashboard.';
  END IF;
  
  -- Créer le profil
  INSERT INTO public.users (id, email, role)
  VALUES (user_id, 'admin@smartdelivery.com', 'admin')
  ON CONFLICT (id) DO UPDATE SET role = 'admin';
  
  -- Créer l'admin
  INSERT INTO public.admins (id, admin_type)
  VALUES (user_id, 'super_admin')
  ON CONFLICT (id) DO UPDATE SET admin_type = 'super_admin';
  
  RAISE NOTICE '✅ Admin créé avec succès!';
END $$;
```

### Méthode 2 : Via l'API Supabase (Pour développeurs)

Si vous préférez créer l'utilisateur par programmation :

#### Via cURL

```bash
curl -X POST 'https://YOUR_PROJECT.supabase.co/auth/v1/admin/users' \
-H "apikey: YOUR_SERVICE_ROLE_KEY" \
-H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY" \
-H "Content-Type: application/json" \
-d '{
  "email": "admin@smartdelivery.com",
  "password": "Admin123!",
  "email_confirm": true,
  "user_metadata": {
    "name": "Admin"
  }
}'
```

#### Via Flutter/Dart

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

// Créer l'utilisateur admin
final response = await supabase.auth.admin.createUser(
  AdminUserAttributes(
    email: 'admin@smartdelivery.com',
    password: 'Admin123!',
    emailConfirm: true,
    userMetadata: {'name': 'Admin'},
  ),
);

print('User created: ${response.user.id}');

// Créer le profil
await supabase.from('users').insert({
  'id': response.user.id,
  'email': 'admin@smartdelivery.com',
  'role': 'admin',
});

// Créer l'admin
await supabase.from('admins').insert({
  'id': response.user.id,
  'admin_type': 'super_admin',
});
```

## 🔍 Vérification

Après avoir créé l'utilisateur, vérifiez que tout est correct :

```sql
-- Vérifier dans auth.users
SELECT id, email, created_at 
FROM auth.users 
WHERE email = 'admin@smartdelivery.com';

-- Vérifier dans public.users
SELECT id, email, role 
FROM public.users 
WHERE email = 'admin@smartdelivery.com';

-- Vérifier dans public.admins
SELECT u.email, u.role, a.admin_type
FROM public.users u
JOIN public.admins a ON u.id = a.id
WHERE u.email = 'admin@smartdelivery.com';
```

**Résultat attendu** :
```
✅ Utilisateur existe dans auth.users
✅ Profil existe dans public.users avec role = 'admin'
✅ Admin existe dans public.admins avec admin_type = 'super_admin'
```

## 🛠️ Script de Dépannage

Si vous continuez à avoir des problèmes, exécutez ce script de nettoyage :

```sql
-- Script de nettoyage et recréation
DO $$ 
DECLARE
  user_id UUID;
BEGIN
  -- Trouver l'utilisateur
  SELECT id INTO user_id 
  FROM auth.users 
  WHERE email = 'admin@smartdelivery.com';
  
  IF user_id IS NOT NULL THEN
    -- Supprimer les données existantes
    DELETE FROM public.admins WHERE id = user_id;
    DELETE FROM public.users WHERE id = user_id;
    
    -- Recréer proprement
    INSERT INTO public.users (id, email, role)
    VALUES (user_id, 'admin@smartdelivery.com', 'admin');
    
    INSERT INTO public.admins (id, admin_type)
    VALUES (user_id, 'super_admin');
    
    RAISE NOTICE '✅ Admin recréé avec succès!';
  ELSE
    RAISE EXCEPTION 'Utilisateur non trouvé. Créez-le d''abord via le Dashboard.';
  END IF;
END $$;
```

## 📊 Ordre Correct des Opérations

Pour éviter l'erreur de contrainte, suivez cet ordre :

1. ✅ **Créer l'utilisateur dans `auth.users`** (via Dashboard ou API)
2. ✅ **Créer le profil dans `public.users`** (SQL avec l'ID de l'étape 1)
3. ✅ **Créer l'admin dans `public.admins`** (SQL avec l'ID de l'étape 1)

**Important** : `auth.users` doit TOUJOURS être créé en premier !

## 💡 Pourquoi cette erreur ?

La table `public.users` a cette définition :

```sql
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  ...
);
```

La contrainte `REFERENCES auth.users(id)` signifie qu'un ID doit d'abord exister dans `auth.users` avant de pouvoir être utilisé dans `public.users`.

## 🎯 Checklist de Résolution

- [ ] L'utilisateur existe dans `auth.users`
- [ ] L'ID de l'utilisateur est correct
- [ ] Le profil existe dans `public.users` avec `role = 'admin'`
- [ ] L'admin existe dans `public.admins`
- [ ] Les identifiants de connexion fonctionnent

## 🔐 Identifiants par Défaut

- **Email**: `admin@smartdelivery.com`
- **Password**: `Admin123!`
- ⚠️ **Changez ce mot de passe après la première connexion !**


































