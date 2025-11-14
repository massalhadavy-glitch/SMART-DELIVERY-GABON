-- ============================================
-- 🧪 SCRIPT DE TEST - CONNEXION ADMIN
-- ============================================
-- Ce script teste la configuration de l'admin
-- Exécutez-le dans le SQL Editor de Supabase

-- ============================================
-- TEST 1: Vérifier l'utilisateur dans auth.users
-- ============================================
SELECT 
  '🧪 TEST 1: auth.users' as test,
  CASE 
    WHEN COUNT(*) > 0 THEN '✅ PASS - Utilisateur existe'
    ELSE '❌ FAIL - Utilisateur n''existe pas dans auth.users'
  END as resultat,
  COALESCE(MAX(email), 'N/A') as email,
  COALESCE(MAX(id::TEXT), 'N/A') as user_id,
  CASE 
    WHEN MAX(confirmed_at) IS NOT NULL THEN '✅ Email confirmé'
    ELSE '⚠️ Email non confirmé'
  END as statut_confirmation
FROM auth.users
WHERE email = 'admin@smartdelivery.com';

-- ============================================
-- TEST 2: Vérifier l'utilisateur dans public.users
-- ============================================
SELECT 
  '🧪 TEST 2: public.users' as test,
  CASE 
    WHEN COUNT(*) > 0 THEN '✅ PASS - Profil existe'
    ELSE '❌ FAIL - Profil n''existe pas dans public.users'
  END as resultat,
  COALESCE(MAX(email), 'N/A') as email,
  COALESCE(MAX(role), 'N/A') as role,
  CASE 
    WHEN MAX(role) = 'admin' THEN '✅ Rôle admin correct'
    ELSE '❌ Rôle n''est pas admin'
  END as statut_role
FROM public.users
WHERE email = 'admin@smartdelivery.com';

-- ============================================
-- TEST 3: Vérifier l'admin dans public.admins
-- ============================================
SELECT 
  '🧪 TEST 3: public.admins' as test,
  CASE 
    WHEN COUNT(*) > 0 THEN '✅ PASS - Admin configuré'
    ELSE '❌ FAIL - Pas d''entrée dans public.admins'
  END as resultat,
  COALESCE(MAX(admin_type), 'N/A') as admin_type,
  CASE 
    WHEN MAX(admin_type) = 'super_admin' THEN '✅ Super admin'
    WHEN MAX(admin_type) = 'admin' THEN '✅ Admin standard'
    ELSE '⚠️ Type admin non standard'
  END as statut_type
FROM public.admins
WHERE id IN (
  SELECT id FROM auth.users WHERE email = 'admin@smartdelivery.com'
);

-- ============================================
-- TEST 4: Vérifier la synchronisation complète
-- ============================================
SELECT 
  '🧪 TEST 4: Synchronisation' as test,
  CASE 
    WHEN au.id IS NOT NULL AND pu.id IS NOT NULL AND pa.id IS NOT NULL 
    THEN '✅ PASS - Synchronisation complète'
    WHEN au.id IS NOT NULL AND pu.id IS NOT NULL AND pa.id IS NULL
    THEN '⚠️ PARTIAL - Manque entrée admins'
    WHEN au.id IS NOT NULL AND pu.id IS NULL
    THEN '❌ FAIL - Manque profil users'
    ELSE '❌ FAIL - Utilisateur inexistant'
  END as resultat,
  COALESCE(au.id::TEXT, 'NULL') as auth_users_id,
  COALESCE(pu.id::TEXT, 'NULL') as public_users_id,
  COALESCE(pa.id::TEXT, 'NULL') as public_admins_id
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id
LEFT JOIN public.admins pa ON au.id = pa.id
WHERE au.email = 'admin@smartdelivery.com';

-- ============================================
-- TEST 5: Vérifier les tables et triggers
-- ============================================
SELECT 
  '🧪 TEST 5: Tables' as test,
  '✅ Table public.users existe' as resultat
FROM information_schema.tables
WHERE table_schema = 'public' AND table_name = 'users'
UNION ALL
SELECT 
  '🧪 TEST 5: Tables',
  '✅ Table public.admins existe'
FROM information_schema.tables
WHERE table_schema = 'public' AND table_name = 'admins'
UNION ALL
SELECT 
  '🧪 TEST 5: Triggers',
  '✅ Trigger on_auth_user_created existe'
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';

-- ============================================
-- TEST 6: Vérifier les fonctions
-- ============================================
SELECT 
  '🧪 TEST 6: Fonctions' as test,
  CASE 
    WHEN COUNT(*) > 0 THEN '✅ PASS - Fonction create_admin existe'
    ELSE '❌ FAIL - Fonction create_admin manquante'
  END as resultat
FROM pg_proc
WHERE proname = 'create_admin';

-- ============================================
-- TEST 7: Vérifier les politiques RLS
-- ============================================
SELECT 
  '🧪 TEST 7: RLS - ' || tablename as test,
  CASE 
    WHEN rowsecurity THEN '✅ RLS activé'
    ELSE '⚠️ RLS désactivé'
  END as resultat,
  (SELECT COUNT(*) FROM pg_policies WHERE tablename = t.tablename)::TEXT || ' politiques' as nb_policies
FROM pg_tables t
WHERE schemaname = 'public' 
  AND tablename IN ('users', 'admins');

-- ============================================
-- TEST 8: Vue d'ensemble complète
-- ============================================
SELECT 
  '═══════════════════════════════════════════' as separator,
  '🎯 VUE D''ENSEMBLE COMPLÈTE' as titre
UNION ALL
SELECT 
  '═══════════════════════════════════════════',
  ''
UNION ALL
SELECT 
  'Email',
  COALESCE(au.email, 'N/A')
FROM auth.users au
WHERE au.email = 'admin@smartdelivery.com'
UNION ALL
SELECT 
  'User ID',
  COALESCE(au.id::TEXT, 'N/A')
FROM auth.users au
WHERE au.email = 'admin@smartdelivery.com'
UNION ALL
SELECT 
  'Email confirmé',
  CASE 
    WHEN au.confirmed_at IS NOT NULL THEN '✅ Oui (' || au.confirmed_at::TEXT || ')'
    ELSE '❌ Non'
  END
FROM auth.users au
WHERE au.email = 'admin@smartdelivery.com'
UNION ALL
SELECT 
  'Rôle dans public.users',
  COALESCE(pu.role, '❌ Pas de profil')
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id
WHERE au.email = 'admin@smartdelivery.com'
UNION ALL
SELECT 
  'Type dans public.admins',
  COALESCE(pa.admin_type, '❌ Pas d''admin')
FROM auth.users au
LEFT JOIN public.admins pa ON au.id = pa.id
WHERE au.email = 'admin@smartdelivery.com'
UNION ALL
SELECT 
  'Créé le',
  COALESCE(au.created_at::TEXT, 'N/A')
FROM auth.users au
WHERE au.email = 'admin@smartdelivery.com';

-- ============================================
-- DIAGNOSTIC ET RECOMMANDATIONS
-- ============================================
DO $$
DECLARE
  auth_exists BOOLEAN;
  users_exists BOOLEAN;
  admins_exists BOOLEAN;
  user_role TEXT;
BEGIN
  -- Vérifications
  SELECT EXISTS(SELECT 1 FROM auth.users WHERE email = 'admin@smartdelivery.com')
  INTO auth_exists;
  
  SELECT EXISTS(SELECT 1 FROM public.users WHERE email = 'admin@smartdelivery.com')
  INTO users_exists;
  
  SELECT EXISTS(SELECT 1 FROM public.admins WHERE id IN (
    SELECT id FROM auth.users WHERE email = 'admin@smartdelivery.com'
  )) INTO admins_exists;
  
  SELECT role INTO user_role FROM public.users WHERE email = 'admin@smartdelivery.com';
  
  RAISE NOTICE '═══════════════════════════════════════════';
  RAISE NOTICE '🔍 DIAGNOSTIC AUTOMATIQUE';
  RAISE NOTICE '═══════════════════════════════════════════';
  RAISE NOTICE '';
  
  IF NOT auth_exists THEN
    RAISE NOTICE '❌ PROBLÈME: Utilisateur n''existe pas dans auth.users';
    RAISE NOTICE '📝 SOLUTION:';
    RAISE NOTICE '   1. Allez dans Supabase Dashboard > Authentication > Users';
    RAISE NOTICE '   2. Cliquez sur "Add User"';
    RAISE NOTICE '   3. Email: admin@smartdelivery.com';
    RAISE NOTICE '   4. Password: Admin123!';
    RAISE NOTICE '   5. ✅ Cochez "Auto Confirm User"';
    RAISE NOTICE '';
  ELSIF NOT users_exists THEN
    RAISE NOTICE '❌ PROBLÈME: Utilisateur existe dans auth.users mais pas dans public.users';
    RAISE NOTICE '📝 SOLUTION: Exécutez cette commande:';
    RAISE NOTICE '   INSERT INTO public.users (id, email, role)';
    RAISE NOTICE '   SELECT id, email, ''admin'' FROM auth.users';
    RAISE NOTICE '   WHERE email = ''admin@smartdelivery.com'';';
    RAISE NOTICE '';
  ELSIF user_role != 'admin' THEN
    RAISE NOTICE '❌ PROBLÈME: Utilisateur existe mais rôle n''est pas ''admin'' (rôle actuel: %)', user_role;
    RAISE NOTICE '📝 SOLUTION: Exécutez cette commande:';
    RAISE NOTICE '   SELECT public.create_admin(''admin@smartdelivery.com'', ''super_admin'');';
    RAISE NOTICE '';
  ELSIF NOT admins_exists THEN
    RAISE NOTICE '⚠️  PROBLÈME: Utilisateur a le rôle admin mais pas d''entrée dans public.admins';
    RAISE NOTICE '📝 SOLUTION: Exécutez cette commande:';
    RAISE NOTICE '   SELECT public.create_admin(''admin@smartdelivery.com'', ''super_admin'');';
    RAISE NOTICE '';
  ELSE
    RAISE NOTICE '✅ TOUT EST CORRECT!';
    RAISE NOTICE '';
    RAISE NOTICE '🎉 Configuration admin complète et fonctionnelle';
    RAISE NOTICE '📧 Email: admin@smartdelivery.com';
    RAISE NOTICE '🔑 Password: Admin123!';
    RAISE NOTICE '';
    RAISE NOTICE '🧪 Vous pouvez maintenant tester la connexion dans l''application';
    RAISE NOTICE '';
  END IF;
  
  RAISE NOTICE '═══════════════════════════════════════════';
END $$;

-- ============================================
-- RÉSUMÉ DES STATISTIQUES
-- ============================================
SELECT 
  '📊 STATISTIQUES GÉNÉRALES' as titre,
  '' as valeur
UNION ALL
SELECT 
  'Utilisateurs totaux (auth.users)',
  COUNT(*)::TEXT
FROM auth.users
UNION ALL
SELECT 
  'Profils totaux (public.users)',
  COUNT(*)::TEXT
FROM public.users
UNION ALL
SELECT 
  'Admins totaux (public.admins)',
  COUNT(*)::TEXT
FROM public.admins
UNION ALL
SELECT 
  'Utilisateurs avec rôle admin',
  COUNT(*)::TEXT
FROM public.users
WHERE role = 'admin';

