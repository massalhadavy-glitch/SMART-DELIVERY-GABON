-- ============================================
-- 📧 Script pour Mettre à Jour l'Email de l'Admin
-- ============================================
-- Ce script change l'email de admin@smartdelivery.com vers massalhadavy@gmail.com
-- ============================================

-- IMPORTANT: 
-- Dans Supabase, la modification directe de auth.users nécessite des privilèges élevés.
-- La méthode recommandée est d'utiliser le Dashboard ou l'API Admin.
-- Ce script fait la mise à jour dans public.users et fournit les instructions pour auth.users.

-- ============================================
-- ÉTAPE 1: Vérifier que l'utilisateur existe
-- ============================================
DO $$ 
DECLARE
  old_email TEXT := 'admin@smartdelivery.com';
  new_email TEXT := 'massalhadavy@gmail.com';
  user_id_val UUID;
  user_exists BOOLEAN;
BEGIN
  -- Vérifier l'existence
  SELECT EXISTS(
    SELECT 1 FROM auth.users WHERE email = old_email
  ) INTO user_exists;
  
  IF NOT user_exists THEN
    RAISE EXCEPTION '❌ Utilisateur avec email % non trouvé dans auth.users', old_email;
  END IF;
  
  -- Récupérer l'ID
  SELECT id INTO user_id_val
  FROM auth.users
  WHERE email = old_email;
  
  RAISE NOTICE '✅ Utilisateur trouvé: % (ID: %)', old_email, user_id_val;
END $$;

-- ============================================
-- ÉTAPE 2: Mettre à jour dans auth.users
-- ============================================
-- ATTENTION: Cette opération nécessite des privilèges SERVICE_ROLE
-- Si cela ne fonctionne pas, utilisez le Dashboard Supabase (voir instructions ci-dessous)

DO $$ 
DECLARE
  old_email TEXT := 'admin@smartdelivery.com';
  new_email TEXT := 'massalhadavy@gmail.com';
  user_id_val UUID;
BEGIN
  -- Récupérer l'ID
  SELECT id INTO user_id_val
  FROM auth.users
  WHERE email = old_email;
  
  IF user_id_val IS NULL THEN
    RAISE EXCEPTION '❌ Utilisateur non trouvé';
  END IF;
  
  -- Tenter la mise à jour dans auth.users
  BEGIN
    UPDATE auth.users
    SET 
      email = new_email,
      email_confirmed_at = COALESCE(email_confirmed_at, NOW()),
      updated_at = NOW()
    WHERE id = user_id_val;
    
    RAISE NOTICE '✅ Email mis à jour dans auth.users: % → %', old_email, new_email;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE WARNING '⚠️  Privilèges insuffisants pour modifier auth.users directement';
    RAISE NOTICE '';
    RAISE NOTICE '📋 UTILISEZ LE DASHBOARD SUPABASE:';
    RAISE NOTICE '1. Allez dans Authentication > Users';
    RAISE NOTICE '2. Trouvez l''utilisateur: %', old_email;
    RAISE NOTICE '3. Cliquez sur l''utilisateur pour ouvrir les détails';
    RAISE NOTICE '4. Cliquez sur "Edit" ou le crayon (✏️)';
    RAISE NOTICE '5. Changez l''email vers: %', new_email;
    RAISE NOTICE '6. Sauvegardez';
    RAISE NOTICE '7. Relancez ce script pour mettre à jour public.users';
    RAISE NOTICE '';
  END;
END $$;

-- ============================================
-- ÉTAPE 3: Mettre à jour dans public.users
-- ============================================
UPDATE public.users
SET 
  email = 'massalhadavy@gmail.com',
  updated_at = NOW()
WHERE id IN (
  SELECT id FROM auth.users 
  WHERE email = 'admin@smartdelivery.com' 
     OR email = 'massalhadavy@gmail.com'
);

DO $$ 
BEGIN
  RAISE NOTICE '✅ Email mis à jour dans public.users';
END $$;

-- ============================================
-- ÉTAPE 4: Vérification
-- ============================================
SELECT 
  '🔍 VÉRIFICATION' as section,
  au.id,
  au.email as email_auth,
  pu.email as email_public,
  pu.role,
  pa.admin_type,
  CASE 
    WHEN au.email = 'massalhadavy@gmail.com' AND pu.email = 'massalhadavy@gmail.com' 
    THEN '✅ Email mis à jour avec succès'
    ELSE '⚠️ Emails non synchronisés'
  END as status
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id
LEFT JOIN public.admins pa ON au.id = pa.id
WHERE au.email IN ('admin@smartdelivery.com', 'massalhadavy@gmail.com')
   OR pu.email IN ('admin@smartdelivery.com', 'massalhadavy@gmail.com');

-- ============================================
-- ÉTAPE 5: Instructions pour mise à jour via Dashboard
-- ============================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════════════════════';
  RAISE NOTICE '📋 MÉTHODE ALTERNATIVE : Via Dashboard Supabase';
  RAISE NOTICE '═══════════════════════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE 'Si la mise à jour de auth.users a échoué, utilisez le Dashboard:';
  RAISE NOTICE '';
  RAISE NOTICE '1. Allez sur https://app.supabase.com';
  RAISE NOTICE '2. Sélectionnez votre projet';
  RAISE NOTICE '3. Menu: Authentication > Users';
  RAISE NOTICE '4. Trouvez: admin@smartdelivery.com';
  RAISE NOTICE '5. Cliquez sur l''utilisateur';
  RAISE NOTICE '6. Cliquez sur "Edit" (✏️) ou les trois points (...)';
  RAISE NOTICE '7. Changez l''email vers: massalhadavy@gmail.com';
  RAISE NOTICE '8. Cliquez sur "Save"';
  RAISE NOTICE '9. Relancez ce script pour synchroniser public.users';
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '🔐 NOUVEAUX IDENTIFIANTS DE CONNEXION:';
  RAISE NOTICE '';
  RAISE NOTICE '📧 Email:    massalhadavy@gmail.com';
  RAISE NOTICE '🔑 Password: Admin123! (ou votre mot de passe actuel)';
  RAISE NOTICE '';
  RAISE NOTICE '⚠️  Après la mise à jour, utilisez le NOUVEL EMAIL pour vous connecter!';
  RAISE NOTICE '';
END $$;







