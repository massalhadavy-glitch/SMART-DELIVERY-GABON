# 🚀 Guide Complet - Créer un Compte Admin Authentifié via Supabase

Ce guide vous explique comment créer un compte administrateur authentifié via Supabase, sans aucune connexion "en dur" dans le code.

## 📋 Vue d'Ensemble

L'application utilise **Supabase Auth** pour l'authentification admin. Il n'y a **aucune connexion en dur** dans le code Flutter. Le système fonctionne ainsi :

1. ✅ L'utilisateur se connecte avec email/password via Supabase Auth
2. ✅ Le code vérifie le rôle dans la table `public.users`
3. ✅ Si `role = 'admin'`, l'accès admin est accordé

## 🔧 Étapes de Configuration

### Étape 1 : Exécuter la Migration SQL (si pas déjà fait)

1. Ouvrez **Supabase Dashboard** : https://app.supabase.com
2. Sélectionnez votre projet
3. Allez dans **SQL Editor**
4. Exécutez le fichier : `supabase/migrations/001_create_admin_user.sql`

Cette migration crée :
- ✅ La table `public.users` avec gestion des rôles
- ✅ La table `public.admins` 
- ✅ Les fonctions et triggers nécessaires
- ✅ Les politiques RLS (Row Level Security)

### Étape 2 : Créer l'Utilisateur dans Supabase Auth

1. Dans le **Dashboard Supabase**
2. Allez dans **Authentication** > **Users**
3. Cliquez sur **"Add User"** (bouton vert en haut à droite)
4. Sélectionnez **"Create new user"**
5. Remplissez le formulaire :
   ```
   📧 Email: admin@smartdelivery.com
   🔑 Password: Admin123!
   ✅ Auto Confirm User: COCHÉ (IMPORTANT!)
   ```
6. Cliquez sur **"Create User"**

⚠️ **IMPORTANT** : Cochez bien **"Auto Confirm User"** pour que l'utilisateur puisse se connecter immédiatement.

### Étape 3 : Exécuter le Script de Promotion en Admin

1. Dans le **SQL Editor** de Supabase
2. Cliquez sur **"New Query"**
3. Copiez-collez le contenu du fichier : `CREATE_ADMIN_SUPABASE_AUTH.sql`
4. Cliquez sur **"Run"** ou appuyez sur `Ctrl+Enter`

Ce script va :
- ✅ Vérifier que l'utilisateur existe dans `auth.users`
- ✅ Synchroniser l'utilisateur dans `public.users` avec `role = 'admin'`
- ✅ Créer l'entrée dans `public.admins` avec `admin_type = 'super_admin'`
- ✅ Afficher un diagnostic complet

### Étape 4 : Vérifier la Configuration

Exécutez cette requête pour vérifier que tout est correct :

```sql
SELECT 
  au.email,
  au.email_confirmed_at,
  pu.role,
  pa.admin_type,
  pu.created_at
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id
LEFT JOIN public.admins pa ON au.id = pa.id
WHERE au.email = 'admin@smartdelivery.com';
```

**Résultat attendu :**
```
email                      | email_confirmed_at | role  | admin_type  | created_at
--------------------------|--------------------|-------|-------------|------------
admin@smartdelivery.com   | 2024-...          | admin | super_admin | 2024-...
```

## 🔐 Identifiants de Connexion

- **Email** : `admin@smartdelivery.com`
- **Password** : `Admin123!`

⚠️ **IMPORTANT** : Changez ce mot de passe après votre première connexion !

## 🧪 Test de Connexion

1. **Lancez l'application Flutter**
   ```bash
   flutter run
   ```

2. **Accédez à la page de connexion admin**
   - Sur la page d'accueil, cliquez sur l'icône admin

3. **Connectez-vous**
   - Email: `admin@smartdelivery.com`
   - Password: `Admin123!`

4. **Vérifiez les logs**
   Dans la console Flutter, vous devriez voir :
   ```
   📧 Tentative de connexion avec: admin@smartdelivery.com
   ✅ Connexion réussie pour userId: [uuid]
   🔍 Vérification du rôle dans la table users pour userId: [uuid]
   📊 Réponse de la requête users: {role: admin}
   ✅ Connexion réussie en tant qu'Administrateur
   ✅ Rôle final: admin
   🎉 Accès admin accordé!
   ```

## 📊 Architecture de l'Authentification

### Tables Utilisées

1. **`auth.users`** (Supabase Auth)
   - Stocke les utilisateurs authentifiés
   - Gère l'authentification email/password
   - Créé via le Dashboard Supabase

2. **`public.users`** (Votre base de données)
   - Stocke les profils utilisateurs
   - Contient le champ `role` : `'user'` ou `'admin'`
   - Synchronisé automatiquement via trigger

3. **`public.admins`** (Votre base de données)
   - Stocke les informations spécifiques aux admins
   - Contient le champ `admin_type` : `'super_admin'`, `'admin'`, etc.

### Flux d'Authentification

```
1. Utilisateur entre email/password dans l'app
   ↓
2. Flutter appelle: Supabase.auth.signInWithPassword()
   ↓
3. Supabase Auth vérifie les credentials dans auth.users
   ↓
4. Si OK, retourne l'utilisateur authentifié
   ↓
5. Flutter interroge public.users pour vérifier le rôle
   ↓
6. Si role = 'admin', l'accès admin est accordé
```

### Code Flutter (déjà implémenté)

Le code dans `lib/providers/auth_notifier.dart` utilise déjà Supabase Auth :

```dart
Future<AuthResponse> loginWithEmail(String email, String password) async {
  // Connexion via Supabase Auth
  final response = await _supabase.auth.signInWithPassword(
    email: email,
    password: password,
  );

  // Vérification du rôle dans public.users
  final userData = await _supabase
      .from('users')
      .select('role')
      .eq('id', response.user!.id)
      .maybeSingle();

  if (userData != null && userData['role'] == 'admin') {
    _role = 'admin';
  }
  
  return response;
}
```

**Aucune connexion en dur !** ✅

## 🔒 Sécurité

### Bonnes Pratiques

1. ✅ **Changez le mot de passe par défaut** après la première connexion
2. ✅ **Utilisez un mot de passe fort** (12+ caractères, majuscules, minuscules, chiffres, caractères spéciaux)
3. ✅ **Activez l'authentification à deux facteurs** si possible
4. ✅ **Surveillez les logs de connexion** dans Supabase Dashboard

### Politiques RLS

Les politiques Row Level Security (RLS) sont déjà configurées dans la migration :
- ✅ Les utilisateurs peuvent voir leur propre profil
- ✅ Les admins peuvent voir les autres admins
- ✅ Seuls les super admins peuvent créer des admins

## 🛠️ Dépannage

### Problème : "Utilisateur non trouvé"

**Solution** : Créez l'utilisateur via le Dashboard Supabase (Étape 2)

### Problème : "Accès refusé : Vous n'êtes pas autorisé comme administrateur"

**Solution** : Vérifiez que `role = 'admin'` dans `public.users`

```sql
SELECT email, role 
FROM public.users 
WHERE email = 'admin@smartdelivery.com';
```

Si le rôle n'est pas 'admin', exécutez :

```sql
UPDATE public.users 
SET role = 'admin' 
WHERE email = 'admin@smartdelivery.com';
```

### Problème : "Email non confirmé"

**Solution** : L'utilisateur doit être confirmé. Vérifiez dans le Dashboard :
- Authentication > Users > [votre utilisateur] > Email Confirmed doit être ✅

Ou recréez l'utilisateur en cochant **"Auto Confirm User"**

### Problème : "Erreur de connexion réseau"

**Solution** : Vérifiez la configuration Supabase dans `lib/config/supabase_config.dart`

## 📝 Scripts Utiles

### Vérifier l'admin

```sql
SELECT 
  au.email,
  au.email_confirmed_at,
  pu.role,
  pa.admin_type
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id
LEFT JOIN public.admins pa ON au.id = pa.id
WHERE au.email = 'admin@smartdelivery.com';
```

### Promouvoir un utilisateur en admin

```sql
-- Remplacer 'email@example.com' par l'email de l'utilisateur
SELECT public.create_admin('email@example.com', 'super_admin');
```

### Voir tous les admins

```sql
SELECT 
  u.email,
  u.role,
  a.admin_type,
  u.created_at
FROM public.users u
LEFT JOIN public.admins a ON u.id = a.id
WHERE u.role = 'admin';
```

## ✅ Checklist Finale

Avant de tester la connexion, assurez-vous que :

- [ ] La migration SQL a été exécutée
- [ ] L'utilisateur existe dans `auth.users`
- [ ] L'utilisateur est confirmé (`email_confirmed_at` n'est pas NULL)
- [ ] L'utilisateur existe dans `public.users` avec `role = 'admin'`
- [ ] L'utilisateur existe dans `public.admins` avec `admin_type = 'super_admin'`
- [ ] Les politiques RLS sont activées
- [ ] La configuration Supabase est correcte dans l'app

## 🎉 Conclusion

Vous avez maintenant un compte admin **100% authentifié via Supabase**, sans aucune connexion en dur dans le code. Le système est sécurisé et suit les meilleures pratiques d'authentification.





