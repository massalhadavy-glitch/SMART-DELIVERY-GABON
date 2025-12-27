# 🔧 Guide - Correction du Search Path des Fonctions

## 🎯 Problème

PostgreSQL affiche des avertissements de sécurité concernant les fonctions avec `SECURITY DEFINER` :

```
Function public.create_admin has a role mutable search_path
Function public.handle_new_user has a role mutable search_path
Function public.is_user_admin has a role mutable search_path
```

## ⚠️ Pourquoi c'est important ?

Les fonctions avec `SECURITY DEFINER` s'exécutent avec les privilèges du propriétaire de la fonction. Si le `search_path` n'est pas fixe, un attaquant pourrait créer un schéma malveillant et exécuter du code SQL non autorisé.

## ✅ Solution

Définir un `search_path` fixe pour toutes les fonctions `SECURITY DEFINER`.

## 📋 Étapes pour Corriger

### Étape 1 : Ouvrir Supabase Dashboard

1. Allez sur https://app.supabase.com
2. Sélectionnez votre projet
3. Ouvrez le **SQL Editor** (menu de gauche)

### Étape 2 : Exécuter le Script de Correction

1. Ouvrez le fichier `FIX_FUNCTIONS_SEARCH_PATH.sql`
2. Copiez tout le contenu
3. Collez-le dans le SQL Editor
4. Cliquez sur **Run** ou appuyez sur `Ctrl+Enter`

### Étape 3 : Vérifier les Résultats

Après l'exécution, vous devriez voir :

```
✅ search_path défini
```

Pour chaque fonction dans les résultats de la requête de vérification.

## 🔍 Vérification Manuelle

Si vous voulez vérifier manuellement, exécutez cette requête :

```sql
SELECT 
  p.proname as function_name,
  CASE 
    WHEN p.proconfig IS NULL THEN '❌ search_path non défini'
    WHEN array_to_string(p.proconfig, ', ') LIKE '%search_path%' THEN '✅ search_path défini'
    ELSE '⚠️ Configuration inattendue'
  END as search_path_status
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname IN ('handle_new_user', 'create_admin', 'is_user_admin')
ORDER BY p.proname;
```

**Résultat attendu :**
- Toutes les fonctions doivent afficher `✅ search_path défini`

## 📝 Fonctions Corrigées

1. **`public.handle_new_user()`**
   - Synchronise automatiquement les nouveaux utilisateurs
   - `SET search_path = public, pg_temp`

2. **`public.create_admin()`**
   - Crée un administrateur
   - `SET search_path = public, pg_temp`

3. **`public.is_user_admin()`**
   - Vérifie si un utilisateur est admin
   - `SET search_path = public, pg_temp`

## 🔒 Sécurité

Le `search_path` fixe garantit que :
- Les fonctions ne peuvent pas être détournées par des schémas malveillants
- L'exécution se fait uniquement dans les schémas autorisés (`public` et `pg_temp`)
- Les attaques par injection SQL sont empêchées

## ✅ Après la Correction

Une fois le script exécuté :
- ✅ Les avertissements PostgreSQL disparaîtront
- ✅ Les fonctions seront sécurisées
- ✅ L'application continuera de fonctionner normalement

## 🚨 Important

**Ne supprimez pas** le `SET search_path` des fonctions. C'est une mesure de sécurité essentielle pour PostgreSQL.

## 📞 Support

Si vous rencontrez des problèmes :
1. Vérifiez que vous êtes connecté en tant qu'administrateur Supabase
2. Vérifiez que les fonctions existent dans votre base de données
3. Consultez les logs dans Supabase Dashboard → Logs



