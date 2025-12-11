-- ============================================
-- Script Simple : Créer le Profil Admin
-- Exécutez CE script APRÈS avoir créé l'utilisateur dans auth.users
-- ============================================

-- Ce script :
-- 1. Trouve l'utilisateur admin@smartdelivery.com dans auth.users
-- 2. Crée son profil dans public.users
-- 3. Crée son admin dans public.admins

DO $$ 
DECLARE
  user_id UUID;
  user_exists BOOLEAN;
BEGIN
  -- Vérifier si l'utilisateur existe dans auth.users
  SELECT id, EXISTS(SELECT 1 FROM auth.users WHERE email = 'admin@smartdelivery.com')
  INTO user_id, user_exists
  FROM auth.users 
  WHERE email = 'admin@smartdelivery.com';
  
  IF NOT user_exists THEN
    RAISE NOTICE '';
    RAISE NOTICE '==========================================';
    RAISE NOTICE '❌ ERREUR: Utilisateur non trouvé';
    RAISE NOTICE '==========================================';
    RAISE NOTICE '';
    RAISE NOTICE '👤 CRÉEZ D''ABORD L''UTILISATEUR :';
    RAISE NOTICE '';
    RAISE NOTICE '1. Allez dans Supabase Dashboard';
    RAISE NOTICE '2. Authentication > Users';
    RAISE NOTICE '3. Add User > Create new user';
    RAISE NOTICE '4. Email: admin@smartdelivery.com';
    RAISE NOTICE '5. Password: Admin123!';
    RAISE NOTICE '6. ✅ Cochez "Auto Confirm User"';
    RAISE NOTICE '7. Cliquez "Create User"';
    RAISE NOTICE '8. Relancez ce script';
    RAISE NOTICE '';
    RAISE NOTICE '==========================================';
    RAISE EXCEPTION 'Utilisateur non trouvé dans auth.users';
  END IF;
  
  RAISE NOTICE '✅ Utilisateur trouvé: %', user_id;
  RAISE NOTICE '';
  
  -- Créer ou mettre à jour le profil dans public.users
  INSERT INTO public.users (id, email, role)
  VALUES (user_id, 'admin@smartdelivery.com', 'admin')
  ON CONFLICT (id) DO UPDATE 
    SET role = 'admin', 
        email = 'admin@smartdelivery.com',
        updated_at = NOW();
  
  RAISE NOTICE '✅ Profil créé dans public.users';
  
  -- Créer ou mettre à jour l'admin dans public.admins
  INSERT INTO public.admins (id, admin_type)
  VALUES (user_id, 'super_admin')
  ON CONFLICT (id) DO UPDATE 
    SET admin_type = 'super_admin', 
        updated_at = NOW();
  
  RAISE NOTICE '✅ Admin créé dans public.admins';
  RAISE NOTICE '';
  
END $$;

-- Afficher le résultat
SELECT 
  '🎉 ADMIN CONFIGURÉ AVEC SUCCÈS!' as status,
  u.email,
  u.role,
  a.admin_type,
  u.created_at
FROM public.users u
LEFT JOIN public.admins a ON u.id = a.id
WHERE u.email = 'admin@smartdelivery.com';

-- Afficher les identifiants
SELECT 
  '🔐 IDENTIFIANTS' as info,
  'admin@smartdelivery.com' as email,
  'Admin123!' as password,
  '⚠️ Changez ce mot de passe!' as warning;


































