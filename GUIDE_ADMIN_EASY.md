# 🚀 Guide Simplifié : Créer l'Admin en 3 Étapes

## 📋 Méthode Recommandée (Dashboard Supabase)

### Étape 1 : Créer l'utilisateur dans Authentication

1. **Connectez-vous au Dashboard Supabase**
   - Allez sur https://app.supabase.com
   - Sélectionnez votre projet

2. **Créez l'utilisateur**
   - Menu gauche : **Authentication** > **Users**
   - Cliquez sur **"Add User"**
   - Cliquez sur **"Create new user"**

3. **Remplissez le formulaire**
   ```
   Email: admin@smartdelivery.com
   Password: Admin123!
   ✅ Cochez "Auto Confirm User"
   ✅ Cochez "Send password reset email" (optionnel)
   ```

4. **Créez l'utilisateur**
   - Cliquez sur **"Create User"**
   - ✅ Utilisateur créé !

### Étape 2 : Exécuter la Migration SQL

Dans le **SQL Editor** de Supabase :

1. Cliquez sur **"New Query"**
2. Copiez-collez le contenu de `supabase/migrations/001_create_admin_user.sql`
3. Cliquez sur **"Run"**

Cette migration crée :
- ✅ La table `users` avec les rôles
- ✅ La table `admins` 
- ✅ Les fonctions et triggers
- ✅ Les politiques RLS

### Étape 3 : Promouvoir l'utilisateur en admin

Dans le **SQL Editor**, exécutez cette requête :

```sql
SELECT public.create_admin('admin@smartdelivery.com', 'super_admin');
```

### Étape 4 : Vérifier

Exécutez cette requête pour vérifier :

```sql
SELECT 
  u.email,
  u.role,
  a.admin_type,
  u.created_at
FROM public.users u
LEFT JOIN public.admins a ON u.id = a.id
WHERE u.email = 'admin@smartdelivery.com';
```

**Résultat attendu :**
```
email                      | role  | admin_type  | created_at
--------------------------|-------|-------------|------------
admin@smartdelivery.com   | admin | super_admin | 2024-...
```

## 🔐 Identifiants de Connexion

- **Email** : `admin@smartdelivery.com`
- **Password** : `Admin123!`

⚠️ **IMPORTANT** : Changez ce mot de passe après la première connexion !

## 🧪 Test de Connexion

1. Lancez l'application Flutter
2. Accédez à la page d'onboarding
3. Cliquez sur l'icône admin en bas
4. Entrez les identifiants ci-dessus
5. ✅ Vous devriez être connecté en tant qu'admin

## 🛠️ Méthode Alternative (Si Dashboard indisponible)

Si vous ne pouvez pas créer l'utilisateur via le Dashboard, vous pouvez utiliser l'API :

### Via cURL

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

### Via l'API REST de Supabase

```dart
// Dans Flutter
final response = await supabase.auth.admin.createUser(
  AdminUserAttributes(
    email: 'admin@smartdelivery.com',
    password: 'Admin123!',
    emailConfirm: true,
    userMetadata: {'name': 'Admin'},
  ),
);
```

## 🔧 Dépannage

### Erreur : "Utilisateur non trouvé"

**Solution** :
```sql
-- Vérifier si l'utilisateur existe
SELECT * FROM auth.users WHERE email = 'admin@smartdelivery.com';

-- Si oui, le promouvoir en admin
SELECT public.create_admin('admin@smartdelivery.com', 'super_admin');
```

### Erreur : "Vous n'êtes pas autorisé comme admin"

**Solution** :
```sql
-- Vérifier le rôle dans users
SELECT role FROM public.users WHERE email = 'admin@smartdelivery.com';

-- Si 'user', le changer en 'admin'
UPDATE public.users 
SET role = 'admin' 
WHERE email = 'admin@smartdelivery.com';
```

### L'utilisateur n'est pas dans public.users

**Solution** :
```sql
-- Insérer manuellement
INSERT INTO public.users (id, email, role)
SELECT id, email, 'admin'
FROM auth.users
WHERE email = 'admin@smartdelivery.com'
ON CONFLICT (id) DO NOTHING;

-- Puis créer l'admin
SELECT public.create_admin('admin@smartdelivery.com', 'super_admin');
```

## 📊 Vérifications Utiles

### Voir tous les utilisateurs
```sql
SELECT * FROM public.users ORDER BY created_at DESC;
```

### Voir tous les admins
```sql
SELECT 
  u.email,
  u.role,
  a.admin_type,
  u.created_at
FROM public.users u
JOIN public.admins a ON u.id = a.id;
```

### Supprimer un admin
```sql
-- Supprimer de admins
DELETE FROM public.admins WHERE id IN (
  SELECT id FROM auth.users WHERE email = 'admin@smartdelivery.com'
);

-- Changer le rôle en user
UPDATE public.users 
SET role = 'user' 
WHERE email = 'admin@smartdelivery.com';
```

## 🎯 Checklist de Vérification

- [ ] Utilisateur créé dans `auth.users`
- [ ] Profil créé dans `public.users` avec `role = 'admin'`
- [ ] Entrée créée dans `public.admins`
- [ ] Peut se connecter avec email/password
- [ ] Accède à l'interface admin après connexion

## 💡 Notes Importantes

1. **Sécurité** : Changez le mot de passe par défaut
2. **Backup** : Sauvegardez votre base de données avant les migrations
3. **Permissions** : Assurez-vous que les politiques RLS sont configurées
4. **Monitoring** : Surveillez les logs d'authentification pour les tentatives suspectes

## 📞 Support

Si vous rencontrez des problèmes :
1. Vérifiez les logs dans Supabase Dashboard > Logs
2. Vérifiez les politiques RLS dans Database > Policies
3. Vérifiez que les migrations ont été exécutées sans erreur

























