# Guide de Création d'Admin par Défaut

Ce guide vous explique comment créer un administrateur par défaut dans Supabase avec authentification.

## 📋 Prérequis

- Un projet Supabase configuré
- Les migrations SQL exécutées
- Accès au Dashboard Supabase

## 🔧 Étapes de Configuration

### 1. Exécuter la Migration SQL

Dans le Dashboard Supabase, allez dans **SQL Editor** et exécutez le fichier :
```
supabase/migrations/001_create_admin_user.sql
```

Cela créera :
- La table `users` avec les rôles
- La table `admins` pour les administrateurs
- Les fonctions et triggers nécessaires
- Les politiques RLS (Row Level Security)

### 2. Créer l'Utilisateur Admin dans Auth

1. Allez dans **Authentication** > **Users**
2. Cliquez sur **"Add User"** > **"Create new user"**
3. Remplissez les informations :
   - **Email**: `admin@smartdelivery.com`
   - **Password**: `Admin123!`
   - **Auto Confirm User**: ✅ (cochez cette case)
4. Cliquez sur **"Create User"**

### 3. Promouvoir l'Utilisateur au Rôle Admin

Dans le **SQL Editor**, exécutez cette requête :

```sql
SELECT public.create_admin('admin@smartdelivery.com', 'super_admin');
```

### 4. Vérifier que l'Admin a été Créé

Exécutez cette requête pour vérifier :

```sql
SELECT 
  u.id,
  u.email,
  u.role,
  a.admin_type,
  u.created_at
FROM public.users u
LEFT JOIN public.admins a ON u.id = a.id
WHERE u.role = 'admin';
```

Vous devriez voir l'utilisateur admin avec :
- Email: `admin@smartdelivery.com`
- Role: `admin`
- Admin type: `super_admin`

## 🔐 Informations de Connexion

- **Email**: `admin@smartdelivery.com`
- **Mot de passe**: `Admin123!`

⚠️ **IMPORTANT**: Changez ce mot de passe après votre première connexion !

## 🧪 Test de Connexion

1. Lancez l'application
2. Accédez à la page d'onboarding
3. Cliquez sur l'icône admin en bas
4. Entrez les identifiants :
   - Email: `admin@smartdelivery.com`
   - Mot de passe: `Admin123!`
5. Vous devriez être connecté en tant qu'admin

## 🛠️ Dépannage

### L'erreur "Vous n'êtes pas autorisé comme admin"

**Solution**:
1. Vérifiez que l'utilisateur existe dans `auth.users`
2. Vérifiez que le rôle est bien `admin` dans la table `users`
3. Exécutez à nouveau `SELECT public.create_admin('admin@smartdelivery.com', 'super_admin');`

### L'utilisateur n'apparaît pas dans la table users

**Solution**:
Le trigger `on_auth_user_created` devrait créer automatiquement le profil.
Si ce n'est pas le cas, créez-le manuellement :

```sql
INSERT INTO public.users (id, email, role)
SELECT id, email, 'user'
FROM auth.users
WHERE email = 'admin@smartdelivery.com'
ON CONFLICT (id) DO NOTHING;
```

Puis promouvez-le en admin :
```sql
SELECT public.create_admin('admin@smartdelivery.com', 'super_admin');
```

## 📊 Structure des Tables

### Table `users` (Profils utilisateurs)
```sql
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT NOT NULL UNIQUE,
  phone TEXT,
  full_name TEXT,
  role TEXT NOT NULL DEFAULT 'user', -- 'user', 'admin', 'driver'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Table `admins` (Administrateurs)
```sql
CREATE TABLE public.admins (
  id UUID PRIMARY KEY REFERENCES public.users(id),
  admin_type TEXT DEFAULT 'super_admin', -- 'super_admin', 'admin', 'moderator'
  permissions JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 🔄 Fonctions Disponibles

### `create_admin(email, admin_type)`
Crée un administrateur à partir d'un email d'utilisateur existant.

```sql
SELECT public.create_admin('user@example.com', 'admin');
```

### `is_user_admin(user_id)`
Vérifie si un utilisateur est admin.

```sql
SELECT public.is_user_admin('user-id-here');
```

## 🔒 Permissions et Sécurité

### Row Level Security (RLS)
- Les utilisateurs ne peuvent voir que leur propre profil
- Les admins peuvent voir tous les profils publics
- Seuls les super admins peuvent créer des admins

### Types d'Admin
- **super_admin**: Accès complet
- **admin**: Accès aux fonctionnalités principales
- **moderator**: Accès limité pour la modération

## 📝 Requêtes Utiles

### Voir tous les utilisateurs
```sql
SELECT * FROM public.users;
```

### Voir tous les admins
```sql
SELECT 
  u.email,
  a.admin_type,
  u.created_at
FROM public.users u
JOIN public.admins a ON u.id = a.id;
```

### Changer le rôle d'un utilisateur
```sql
UPDATE public.users
SET role = 'admin'
WHERE email = 'user@example.com';
```

### Supprimer un admin
```sql
DELETE FROM public.admins WHERE id = 'user-id';
UPDATE public.users SET role = 'user' WHERE id = 'user-id';
```






































