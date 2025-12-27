# 📧 Guide - Changer l'Email de l'Admin

Ce guide vous explique comment changer l'email de l'administrateur de `admin@smartdelivery.com` vers `massalhadavy@gmail.com` (ou tout autre email).

## 🎯 Objectif

Changer l'email de connexion admin tout en conservant :
- ✅ Les droits d'administration
- ✅ Les données associées
- ✅ Le mot de passe (si vous ne voulez pas le changer)

---

## 📋 Méthode 1 : Via le Dashboard Supabase (Recommandée)

C'est la méthode la plus simple et la plus sûre.

### Étape 1 : Modifier l'Email dans Auth

1. **Connectez-vous au Dashboard Supabase**
   - https://app.supabase.com
   - Sélectionnez votre projet

2. **Allez dans Authentication**
   - Menu gauche : **Authentication** > **Users**

3. **Trouvez l'utilisateur admin**
   - Cherchez `admin@smartdelivery.com` dans la liste
   - Cliquez sur l'utilisateur pour ouvrir les détails

4. **Modifiez l'email**
   - Cliquez sur le bouton **"Edit"** (✏️) ou les trois points (...)
   - Dans le champ **"Email"**, remplacez par : `massalhadavy@gmail.com`
   - Cliquez sur **"Save"** ou **"Update"**

✅ L'email dans `auth.users` est maintenant mis à jour !

### Étape 2 : Synchroniser public.users

1. **Ouvrez le SQL Editor** dans Supabase

2. **Exécutez cette requête** :

```sql
-- Mettre à jour l'email dans public.users
UPDATE public.users
SET 
  email = 'massalhadavy@gmail.com',
  updated_at = NOW()
WHERE id IN (
  SELECT id FROM auth.users 
  WHERE email = 'massalhadavy@gmail.com'
);

-- Vérifier
SELECT 
  au.email as email_auth,
  pu.email as email_public,
  pu.role
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id
WHERE au.email = 'massalhadavy@gmail.com';
```

✅ Les deux tables sont maintenant synchronisées !

---

## 📋 Méthode 2 : Via Script SQL Complet

Si vous préférez tout faire via SQL :

1. **Ouvrez le SQL Editor** dans Supabase

2. **Exécutez le script** : `UPDATE_ADMIN_EMAIL.sql`

Ce script :
- ✅ Vérifie que l'utilisateur existe
- ✅ Tente de mettre à jour `auth.users` (peut nécessiter des privilèges élevés)
- ✅ Met à jour `public.users`
- ✅ Vérifie que tout est synchronisé
- ✅ Donne des instructions si quelque chose échoue

**Note** : Si la mise à jour de `auth.users` échoue (privilèges insuffisants), suivez la Méthode 1 pour cette étape, puis relancez le script pour synchroniser `public.users`.

---

## 🔐 Nouveaux Identifiants de Connexion

Après la mise à jour, utilisez :

- **Email** : `massalhadavy@gmail.com`
- **Password** : `Admin123!` (ou votre mot de passe actuel)

⚠️ **IMPORTANT** : Utilisez le **NOUVEL EMAIL** pour vous connecter !

---

## ✅ Vérification

### Vérifier dans Supabase

Exécutez cette requête pour vérifier que tout est correct :

```sql
SELECT 
  au.id,
  au.email as email_auth,
  au.email_confirmed_at,
  pu.email as email_public,
  pu.role,
  pa.admin_type
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id
LEFT JOIN public.admins pa ON au.id = pa.id
WHERE au.email = 'massalhadavy@gmail.com';
```

**Résultat attendu :**
- `email_auth`: `massalhadavy@gmail.com`
- `email_public`: `massalhadavy@gmail.com`
- `role`: `admin`
- `admin_type`: `super_admin`

### Tester la Connexion

1. **Lancez l'application Flutter**
2. **Allez sur la page de connexion admin**
3. **Connectez-vous avec** :
   - Email: `massalhadavy@gmail.com`
   - Password: `Admin123!`

Si la connexion fonctionne, c'est bon ! ✅

---

## ⚠️ Points Importants

### 1. Synchronisation

Assurez-vous que les emails sont synchronisés entre :
- `auth.users` (Supabase Auth)
- `public.users` (votre table de profils)

Les deux doivent avoir le même email !

### 2. Confirmation Email

Après avoir changé l'email dans `auth.users`, Supabase peut envoyer un email de confirmation au nouvel email. Vérifiez votre boîte mail et confirmez si nécessaire.

### 3. Mot de Passe

Le mot de passe reste le même par défaut. Si vous voulez aussi changer le mot de passe :

1. Dashboard Supabase → Authentication → Users
2. Cliquez sur l'utilisateur
3. Cliquez sur "Reset Password"
4. Un email sera envoyé au nouvel email avec un lien de réinitialisation

---

## 🛠️ Dépannage

### Problème : "Utilisateur non trouvé"

**Cause** : L'email `admin@smartdelivery.com` n'existe pas dans `auth.users`

**Solution** :
1. Vérifiez dans Authentication > Users
2. Si l'utilisateur existe avec un autre email, modifiez le script pour utiliser cet email

### Problème : "Privilèges insuffisants"

**Cause** : Vous n'avez pas les droits pour modifier `auth.users` directement via SQL

**Solution** : Utilisez la Méthode 1 (Dashboard) pour modifier `auth.users`, puis le script SQL pour synchroniser `public.users`

### Problème : "Email déjà utilisé"

**Cause** : L'email `massalhadavy@gmail.com` existe déjà dans `auth.users`

**Solution** :
1. Vérifiez dans Authentication > Users si cet email existe
2. Si c'est un autre compte, choisissez un autre email
3. Si c'est le même compte (cas bizarre), tout est déjà bon !

---

## 📝 Script de Vérification Rapide

Pour vérifier rapidement l'état actuel :

```sql
-- Voir tous les emails liés à l'admin
SELECT 
  'auth.users' as table_name,
  email,
  email_confirmed_at IS NOT NULL as is_confirmed
FROM auth.users
WHERE email IN ('admin@smartdelivery.com', 'massalhadavy@gmail.com')

UNION ALL

SELECT 
  'public.users' as table_name,
  email,
  role = 'admin' as is_admin
FROM public.users
WHERE email IN ('admin@smartdelivery.com', 'massalhadavy@gmail.com');
```

---

## ✅ C'est Tout !

Votre email admin est maintenant mis à jour. Utilisez le **nouvel email** pour vous connecter à l'application !

---

## 🔄 Pour Changer Vers un Autre Email

Si vous voulez changer vers un autre email (par exemple `nouveau@email.com`), remplacez simplement :
- `admin@smartdelivery.com` → ancien email
- `massalhadavy@gmail.com` → nouveau email

dans toutes les requêtes ci-dessus.







