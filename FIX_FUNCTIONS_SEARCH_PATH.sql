-- ============================================
-- 🔧 CORRECTION DU SEARCH_PATH POUR LES FONCTIONS
-- ============================================
-- Ce script corrige les avertissements de sécurité concernant
-- le search_path mutable dans les fonctions SECURITY DEFINER
--
-- IMPORTANT: Les fonctions avec SECURITY DEFINER doivent avoir
-- un search_path fixe pour éviter les attaques par injection SQL
-- ============================================

-- ============================================
-- 1. Corriger la fonction handle_new_user
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  INSERT INTO public.users (id, email, role)
  VALUES (
    NEW.id,
    NEW.email,
    'user' -- Par défaut, les nouveaux utilisateurs sont des users
  );
  RETURN NEW;
END;
$$;

-- ============================================
-- 2. Corriger la fonction create_admin
-- ============================================
CREATE OR REPLACE FUNCTION public.create_admin(
  user_email TEXT,
  admin_role TEXT DEFAULT 'super_admin'
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  user_id UUID;
BEGIN
  -- Trouver l'ID de l'utilisateur par email
  SELECT id INTO user_id FROM auth.users WHERE email = user_email;
  
  IF user_id IS NULL THEN
    RAISE EXCEPTION 'Utilisateur non trouvé avec email: %', user_email;
  END IF;
  
  -- Mettre à jour le rôle dans users
  UPDATE public.users
  SET role = 'admin', updated_at = NOW()
  WHERE id = user_id;
  
  -- Insérer dans admins
  INSERT INTO public.admins (id, admin_type)
  VALUES (user_id, admin_role)
  ON CONFLICT (id) DO UPDATE 
    SET admin_type = admin_role, 
        updated_at = NOW();
END;
$$;

-- ============================================
-- 3. Corriger la fonction is_user_admin
-- ============================================
CREATE OR REPLACE FUNCTION public.is_user_admin(user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.users 
    WHERE id = user_id AND role = 'admin'
  );
END;
$$;

-- ============================================
-- 4. Vérification des fonctions corrigées
-- ============================================
SELECT 
  '=== VÉRIFICATION DES FONCTIONS ===' as info,
  p.proname as function_name,
  pg_get_functiondef(p.oid) as function_definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname IN ('handle_new_user', 'create_admin', 'is_user_admin')
ORDER BY p.proname;

-- ============================================
-- 5. Vérifier que le search_path est fixe
-- ============================================
SELECT 
  '=== VÉRIFICATION SEARCH_PATH ===' as info,
  p.proname as function_name,
  CASE 
    WHEN p.proconfig IS NULL THEN '❌ search_path non défini'
    WHEN array_to_string(p.proconfig, ', ') LIKE '%search_path%' THEN '✅ search_path défini'
    ELSE '⚠️ Configuration inattendue'
  END as search_path_status,
  p.proconfig as config
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname IN ('handle_new_user', 'create_admin', 'is_user_admin')
ORDER BY p.proname;

-- ============================================
-- INSTRUCTIONS
-- ============================================
/*
✅ Ce script corrige les avertissements de sécurité PostgreSQL concernant
   le search_path mutable dans les fonctions SECURITY DEFINER.

📋 MODIFICATIONS APPORTÉES:

1. handle_new_user()
   - Ajout de SET search_path = public, pg_temp
   - Sécurise la fonction contre les attaques par injection SQL

2. create_admin()
   - Ajout de SET search_path = public, pg_temp
   - Sécurise la fonction contre les attaques par injection SQL

3. is_user_admin()
   - Ajout de SET search_path = public, pg_temp
   - Sécurise la fonction contre les attaques par injection SQL

🔒 SÉCURITÉ:

Le search_path fixe empêche les attaquants de créer des schémas malveillants
qui pourraient être utilisés pour exécuter du code SQL non autorisé.

📝 POUR APPLIQUER:

1. Ouvrez Supabase Dashboard
2. Allez dans SQL Editor
3. Copiez et exécutez ce script
4. Vérifiez que les fonctions sont bien corrigées

✅ RÉSULTAT ATTENDU:

Après l'exécution, vous ne devriez plus voir les avertissements:
- "Function public.create_admin has a role mutable search_path"
- "Function public.handle_new_user has a role mutable search_path"
- "Function public.is_user_admin has a role mutable search_path"
*/



