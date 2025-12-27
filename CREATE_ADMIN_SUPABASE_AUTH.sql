-- ============================================
-- 🚀 Script Complet - Créer Admin Authentifié via Supabase
-- ============================================
-- Ce script crée un compte admin authentifié via Supabase Auth
-- ============================================

-- ============================================
-- ÉTAPE 1: Vérifier les prérequis
-- ============================================
DO $$ 
BEGIN
  -- Vérifier que la table users existe
  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'users') THEN
    RAISE EXCEPTION '❌ La table public.users n''existe pas. Exécutez d''abord la migration supabase/migrations/001_create_admin_user.sql';
  END IF;
  
  RAISE NOTICE '✅ Table users existe';
END $$;

-- ============================================
-- ÉTAPE 2: Vérifier si l'utilisateur existe déjà dans auth.users
-- ============================================
DO $$ 
DECLARE
  user_exists BOOLEAN;
  user_id_val UUID;
  user_confirmed BOOLEAN;
BEGIN
  -- Vérifier l'existence
  SELECT EXISTS(
    SELECT 1 FROM auth.users WHERE email = 'admin@smartdelivery.com'
  ) INTO user_exists;
  
  IF user_exists THEN
    -- Récupérer l'ID et le statut de confirmation
    SELECT id, COALESCE(email_confirmed_at IS NOT NULL, false) 
    INTO user_id_val, user_confirmed
    FROM auth.users 
    WHERE email = 'admin@smartdelivery.com';
    
    RAISE NOTICE '✅ Utilisateur trouvé dans auth.users';
    RAISE NOTICE '📝 ID: %', user_id_val;
    
    IF NOT user_confirmed THEN
      RAISE WARNING '⚠️ L''utilisateur existe mais n''est pas confirmé. Assurez-vous de cocher "Auto Confirm User" lors de la création.';
    END IF;
  ELSE
    RAISE NOTICE '=================================================';
    RAISE NOTICE '⚠️  UTILISATEUR NON TROUVÉ';
    RAISE NOTICE '=================================================';
    RAISE NOTICE '';
    RAISE NOTICE '📋 INSTRUCTIONS POUR CRÉER L''UTILISATEUR:';
    RAISE NOTICE '';
    RAISE NOTICE '1. Ouvrez le Dashboard Supabase:';
    RAISE NOTICE '   https://app.supabase.com';
    RAISE NOTICE '';
    RAISE NOTICE '2. Sélectionnez votre projet';
    RAISE NOTICE '';
    RAISE NOTICE '3. Allez dans: Authentication > Users';
    RAISE NOTICE '';
    RAISE NOTICE '4. Cliquez sur "Add User" (bouton vert en haut à droite)';
    RAISE NOTICE '';
    RAISE NOTICE '5. Sélectionnez "Create new user"';
    RAISE NOTICE '';
    RAISE NOTICE '6. Remplissez le formulaire:';
    RAISE NOTICE '   📧 Email: admin@smartdelivery.com';
    RAISE NOTICE '   🔑 Password: Admin123!';
    RAISE NOTICE '   ✅ Auto Confirm User: COCHÉ (IMPORTANT!)';
    RAISE NOTICE '';
    RAISE NOTICE '7. Cliquez sur "Create User"';
    RAISE NOTICE '';
    RAISE NOTICE '8. Retournez ici et RELANCEZ ce script';
    RAISE NOTICE '';
    RAISE NOTICE '=================================================';
    RAISE EXCEPTION '❌ Créez d''abord l''utilisateur via le Dashboard Supabase (voir instructions ci-dessus)';
  END IF;
END $$;

-- ============================================
-- ÉTAPE 3: S'assurer que l'utilisateur existe dans public.users
-- ============================================
-- Cette étape synchronise auth.users avec public.users
INSERT INTO public.users (id, email, role)
SELECT 
  au.id,
  au.email,
  'admin' as role
FROM auth.users au
WHERE au.email = 'admin@smartdelivery.com'
ON CONFLICT (id) DO UPDATE 
SET 
  role = 'admin',
  email = EXCLUDED.email,
  updated_at = NOW();

-- Message de confirmation
DO $$ 
BEGIN
  RAISE NOTICE '✅ Utilisateur synchronisé dans public.users avec role=admin';
END $$;

-- ============================================
-- ÉTAPE 4: Créer l'entrée dans public.admins
-- ============================================
INSERT INTO public.admins (id, admin_type)
SELECT id, 'super_admin'
FROM auth.users
WHERE email = 'admin@smartdelivery.com'
ON CONFLICT (id) DO UPDATE 
SET 
  admin_type = 'super_admin',
  updated_at = NOW();

-- Message de confirmation
DO $$ 
BEGIN
  RAISE NOTICE '✅ Admin créé dans public.admins avec type=super_admin';
END $$;

-- ============================================
-- ÉTAPE 5: Vérification finale complète
-- ============================================
SELECT 
  '🎉 ADMIN CRÉÉ AVEC SUCCÈS!' as status,
  au.id,
  au.email,
  au.email_confirmed_at,
  pu.role,
  pa.admin_type,
  pu.created_at,
  pu.updated_at
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id
LEFT JOIN public.admins pa ON au.id = pa.id
WHERE au.email = 'admin@smartdelivery.com';

-- ============================================
-- ÉTAPE 6: Diagnostic complet
-- ============================================
DO $$
DECLARE
  auth_exists BOOLEAN;
  public_exists BOOLEAN;
  admin_exists BOOLEAN;
  role_check TEXT;
  admin_type_check TEXT;
BEGIN
  -- Vérifier auth.users
  SELECT EXISTS(
    SELECT 1 FROM auth.users WHERE email = 'admin@smartdelivery.com'
  ) INTO auth_exists;
  
  -- Vérifier public.users
  SELECT EXISTS(
    SELECT 1 FROM public.users 
    WHERE email = 'admin@smartdelivery.com'
  ) INTO public_exists;
  
  -- Vérifier public.admins
  SELECT EXISTS(
    SELECT 1 FROM public.admins 
    WHERE id IN (SELECT id FROM auth.users WHERE email = 'admin@smartdelivery.com')
  ) INTO admin_exists;
  
  -- Récupérer le rôle
  SELECT role INTO role_check
  FROM public.users
  WHERE email = 'admin@smartdelivery.com';
  
  -- Récupérer le type d'admin
  SELECT admin_type INTO admin_type_check
  FROM public.admins
  WHERE id IN (SELECT id FROM auth.users WHERE email = 'admin@smartdelivery.com');
  
  -- Afficher le diagnostic
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════════════════════';
  RAISE NOTICE '📊 DIAGNOSTIC COMPLET';
  RAISE NOTICE '═══════════════════════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '1. auth.users:        %', CASE WHEN auth_exists THEN '✅ EXISTE' ELSE '❌ MANQUANT' END;
  RAISE NOTICE '2. public.users:      %', CASE WHEN public_exists THEN '✅ EXISTE' ELSE '❌ MANQUANT' END;
  RAISE NOTICE '3. public.admins:     %', CASE WHEN admin_exists THEN '✅ EXISTE' ELSE '❌ MANQUANT' END;
  RAISE NOTICE '4. Rôle dans users:   %', COALESCE(role_check, '❌ NULL');
  RAISE NOTICE '5. Type admin:        %', COALESCE(admin_type_check, '❌ NULL');
  RAISE NOTICE '';
  
  IF auth_exists AND public_exists AND admin_exists AND role_check = 'admin' THEN
    RAISE NOTICE '✅ TOUT EST CORRECT - L''ADMIN EST PRÊT!';
  ELSE
    RAISE NOTICE '⚠️  CERTAINS ÉLÉMENTS MANQUENT - RELANCEZ CE SCRIPT';
  END IF;
  
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════════════════════';
  RAISE NOTICE '🔐 IDENTIFIANTS DE CONNEXION';
  RAISE NOTICE '═══════════════════════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '📧 Email:    admin@smartdelivery.com';
  RAISE NOTICE '🔑 Password: Admin123!';
  RAISE NOTICE '';
  RAISE NOTICE '⚠️  IMPORTANT: Changez ce mot de passe après la première connexion!';
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════════════════════';
END $$;

-- ============================================
-- ÉTAPE 7: Test de connexion (simulation)
-- ============================================
-- Cette requête simule ce que l'application vérifiera
SELECT 
  '🧪 TEST DE CONNEXION (simulation)' as test,
  CASE 
    WHEN EXISTS(
      SELECT 1 FROM public.users 
      WHERE id IN (SELECT id FROM auth.users WHERE email = 'admin@smartdelivery.com')
      AND role = 'admin'
    ) THEN '✅ La connexion admin devrait fonctionner'
    ELSE '❌ La connexion admin ne fonctionnera PAS'
  END as result;









