-- ============================================
-- Script Rapide pour Créer un Admin
-- ============================================
-- IMPORTANT: Exécutez d'abord la migration principale
-- supabase/migrations/001_create_admin_user.sql
-- ============================================

-- Étape 1: Vérifier si la migration a été exécutée
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users') THEN
    RAISE EXCEPTION 'La migration principale n''a pas été exécutée. Exécutez d''abord supabase/migrations/001_create_admin_user.sql';
  END IF;
END $$;

-- Étape 2: Vérifier si l'utilisateur admin@smartdelivery.com existe dans auth.users
DO $$ 
DECLARE
  user_exists BOOLEAN;
BEGIN
  SELECT EXISTS(SELECT 1 FROM auth.users WHERE email = 'admin@smartdelivery.com') INTO user_exists;
  
  IF NOT user_exists THEN
    RAISE NOTICE '=================================================';
    RAISE NOTICE 'ÉTAPE MANQUANTE:';
    RAISE NOTICE '1. Allez dans Authentication > Users';
    RAISE NOTICE '2. Cliquez sur "Add User"';
    RAISE NOTICE '3. Email: admin@smartdelivery.com';
    RAISE NOTICE '4. Password: Admin123!';
    RAISE NOTICE '5. Cochez "Auto Confirm User"';
    RAISE NOTICE '6. Cliquez "Create User"';
    RAISE NOTICE '7. Relancez ce script';
    RAISE NOTICE '=================================================';
    RAISE EXCEPTION 'Utilisateur admin@smartdelivery.com non trouvé. Créez-le d''abord via le Dashboard Supabase.';
  END IF;
END $$;

-- Étape 3: Créer l'admin
SELECT public.create_admin('admin@smartdelivery.com', 'super_admin');

-- Étape 4: Vérifier que l'admin a été créé
SELECT 
  '✅ Admin créé avec succès!' as status,
  u.email,
  u.role,
  a.admin_type,
  u.created_at
FROM public.users u
LEFT JOIN public.admins a ON u.id = a.id
WHERE u.email = 'admin@smartdelivery.com';

-- Étape 5: Afficher les informations de connexion
SELECT 
  '🔐 Identifiants de connexion:' as info,
  'Email: admin@smartdelivery.com' as credential,
  'Password: Admin123!' as password,
  '⚠️ Changez ce mot de passe après la première connexion!' as warning;






















