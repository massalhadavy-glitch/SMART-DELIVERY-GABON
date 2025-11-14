-- ============================================
-- 🔧 CORRECTION SIMPLE - RÔLE ADMIN DANS USERS
-- ============================================
-- Ce script met à jour le rôle dans la table users

-- ============================================
-- ÉTAPE 1: Vérifier l'utilisateur actuel
-- ============================================
SELECT 
  '=== VÉRIFICATION INITIALE ===' as section,
  au.id,
  au.email,
  u.role as role_actuel,
  CASE 
    WHEN u.role = 'admin' THEN '✅ Déjà admin'
    WHEN u.role = 'user' THEN '⚠️ Est user, doit être admin'
    WHEN u.role IS NULL THEN '❌ Pas de rôle'
    ELSE '⚠️ Rôle inconnu: ' || u.role
  END as status
FROM auth.users au
LEFT JOIN public.users u ON au.id = u.id
WHERE au.email = 'admin@smartdelivery.com';

-- ============================================
-- ÉTAPE 2: S'assurer que l'utilisateur existe dans public.users
-- ============================================
INSERT INTO public.users (id, email, role)
SELECT 
  au.id,
  au.email,
  'admin' as role
FROM auth.users au
WHERE au.email = 'admin@smartdelivery.com'
ON CONFLICT (id) DO UPDATE 
SET role = 'admin',
    updated_at = NOW();

-- ============================================
-- ÉTAPE 3: Vérification finale
-- ============================================
SELECT 
  '=== VÉRIFICATION FINALE ===' as section,
  au.id,
  au.email,
  u.role,
  CASE 
    WHEN u.role = 'admin' THEN '✅ SUCCÈS - Utilisateur est admin'
    ELSE '❌ ÉCHEC - Rôle: ' || COALESCE(u.role, 'NULL')
  END as status
FROM auth.users au
LEFT JOIN public.users u ON au.id = u.id
WHERE au.email = 'admin@smartdelivery.com';

-- ============================================
-- ÉTAPE 4: Test de lecture
-- ============================================
-- Tester que l'application peut lire la table users
SELECT 
  '=== TEST DE LECTURE ===' as section,
  COUNT(*) as nombre_users,
  COUNT(CASE WHEN role = 'admin' THEN 1 END) as nombre_admins
FROM public.users;

-- ============================================
-- DIAGNOSTIC COMPLET
-- ============================================
DO $$
DECLARE
  user_exists BOOLEAN;
  user_role TEXT;
  rls_enabled BOOLEAN;
BEGIN
  -- Vérifier existence
  SELECT EXISTS(
    SELECT 1 FROM public.users 
    WHERE id = (SELECT id FROM auth.users WHERE email = 'admin@smartdelivery.com')
  ) INTO user_exists;
  
  -- Récupérer le rôle
  SELECT role INTO user_role
  FROM public.users
  WHERE id = (SELECT id FROM auth.users WHERE email = 'admin@smartdelivery.com');
  
  -- Vérifier RLS
  SELECT rowsecurity INTO rls_enabled
  FROM pg_tables
  WHERE tablename = 'users' AND schemaname = 'public';
  
  RAISE NOTICE '═══════════════════════════════════════════';
  RAISE NOTICE '🔍 DIAGNOSTIC COMPLET';
  RAISE NOTICE '═══════════════════════════════════════════';
  RAISE NOTICE '';
  
  IF NOT user_exists THEN
    RAISE NOTICE '❌ Utilisateur N''EXISTE PAS dans public.users';
    RAISE NOTICE '⚠️  Ceci ne devrait pas arriver après ÉTAPE 2';
  ELSE
    RAISE NOTICE '✅ Utilisateur existe dans public.users';
    
    IF user_role = 'admin' THEN
      RAISE NOTICE '✅ Rôle est "admin" - PARFAIT!';
    ELSE
      RAISE NOTICE '❌ Rôle est "%"- PROBLÈME!', user_role;
      RAISE NOTICE '⚠️  Exécutez à nouveau ce script';
    END IF;
  END IF;
  
  RAISE NOTICE '';
  RAISE NOTICE '🔒 RLS activé sur users: %', rls_enabled;
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════';
  RAISE NOTICE '✅ SCRIPT TERMINÉ';
  RAISE NOTICE '═══════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '🧪 TESTEZ LA CONNEXION MAINTENANT:';
  RAISE NOTICE '📧 Email: admin@smartdelivery.com';
  RAISE NOTICE '🔑 Password: Admin123!';
  RAISE NOTICE '';
  RAISE NOTICE '📋 Logs attendus:';
  RAISE NOTICE '   🔍 Vérification du rôle dans la table users';
  RAISE NOTICE '   📊 Réponse de la requête users: {role: admin}';
  RAISE NOTICE '   ✅ Connexion réussie en tant qu''Administrateur';
  RAISE NOTICE '   ✅ Rôle final: admin';
  RAISE NOTICE '';
END $$;

