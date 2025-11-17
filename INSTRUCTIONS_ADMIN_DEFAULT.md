# Instructions pour créer un Admin par défaut dans Supabase

## 📋 Étapes pour configurer un administrateur par défaut

### 1. Créer l'utilisateur dans Supabase Auth

1. Connectez-vous à votre projet Supabase
2. Allez dans **Authentication** > **Users**
3. Cliquez sur **Add User** > **Create new user**
4. Entrez les informations suivantes :
   - **Email**: `admin@smartdelivery.com`
   - **Password**: `Admin123!`
   - **Auto Confirm User**: ✅ (cochez cette case)

### 2. Obtenir l'ID de l'utilisateur

1. Après avoir créé l'utilisateur, notez son **UUID** (ID)
2. Vous le verrez dans la liste des utilisateurs

### 3. Insérer l'admin dans la table `admins`

Exécutez cette requête SQL dans l'éditeur SQL de Supabase :

```sql
-- Remplacez 'USER_ID_HERE' par l'UUID de l'utilisateur créé
INSERT INTO admins (id, role)
VALUES ('USER_ID_HERE', 'admin');
```

### 4. Alternative : Création automatique via Dashboard

Vous pouvez aussi utiliser l'interface SQL Editor de Supabase pour créer automatiquement un admin :

```sql
-- Cette fonction crée un admin pour n'importe quel utilisateur
CREATE OR REPLACE FUNCTION make_user_admin(user_email TEXT)
RETURNS void AS $$
DECLARE
  user_uuid UUID;
BEGIN
  -- Trouver l'ID de l'utilisateur par email
  SELECT id INTO user_uuid FROM auth.users WHERE email = user_email;
  
  -- Insérer dans la table admins
  IF user_uuid IS NOT NULL THEN
    INSERT INTO public.admins (id, role)
    VALUES (user_uuid, 'admin')
    ON CONFLICT (id) DO NOTHING;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Appeler la fonction pour créer l'admin
SELECT make_user_admin('admin@smartdelivery.com');
```

## 🔐 Identifiants par défaut

- **Email**: `admin@smartdelivery.com`
- **Mot de passe**: `Admin123!`

⚠️ **IMPORTANT**: Changez ce mot de passe après votre première connexion !

## 🔑 Permissions

Assurez-vous que la table `admins` a les bonnes permissions :

1. Allez dans **Authentication** > **Policies**
2. Vérifiez que les politiques RLS sont activées
3. Ajoutez des politiques personnalisées si nécessaire

## 📱 Test de connexion

Après avoir créé l'admin :

1. Ouvrez l'application
2. Allez sur la page d'onboarding
3. Cliquez sur l'icône admin en bas
4. Entrez :
   - Email : `admin@smartdelivery.com`
   - Mot de passe : `Admin123!`
5. Vous devriez être connecté en tant qu'admin

## 🔧 Dépannage

### Erreur "Vous n'êtes pas autorisé comme admin"
- Vérifiez que l'utilisateur existe dans `auth.users`
- Vérifiez que l'entrée existe dans la table `admins`
- Vérifiez que `role = 'admin'` dans la table admins

### L'utilisateur n'apparaît pas dans auth.users
- Vérifiez que l'auto-confirmation est activée
- Vérifiez que l'email est correct
- Vérifiez les logs dans Supabase Dashboard

## 📝 Exemple de requête complète

```sql
-- 1. Vérifier si la table existe
SELECT * FROM admins;

-- 2. Vérifier les utilisateurs
SELECT id, email, created_at FROM auth.users;

-- 3. Créer l'admin (remplacez USER_ID par l'ID de votre utilisateur)
INSERT INTO admins (id, role)
VALUES ('USER_ID', 'admin')
ON CONFLICT (id) DO NOTHING;

-- 4. Vérifier l'admin créé
SELECT * FROM admins WHERE role = 'admin';
```

























