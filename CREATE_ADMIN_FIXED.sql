-- ============================================
-- Script Corrigé pour Créer un Admin
-- Ce script gère correctement la contrainte de clé étrangère
-- ============================================

-- Étape 1: Supprimer l'admin existant s'il y a des erreurs
DO $$ 
DECLARE
  existing_user_id UUID;
BEGIN
  -- Chercher l'utilisateur existant
  SELECT id INTO existing_user_id 
  FROM auth.users 
  WHERE email = 'admin@smartdelivery.com';
  
  IF existing_user_id IS NOT NULL THEN
    RAISE NOTICE '🔍 Utilisateur trouvé dans auth.users: %', existing_user_id;
    
    -- Vérifier si le profil existe dans public.users
    IF EXISTS (SELECT 1 FROM public.users WHERE id = existing_user_id) THEN
      RAISE NOTICE '✅ Profil existe déjà dans public.users';
    ELSE
      RAISE NOTICE '📝 Création du profil dans public.users...';
      -- Créer le profil
      INSERT INTO public.users (id, email, role)
      VALUES (existing_user_id, 'admin@smartdelivery.com', 'admin');
    END IF;
    
    -- Vérifier si l'admin existe
    IF EXISTS (SELECT 1 FROM public.admins WHERE id = existing_user_id) THEN
      RAISE NOTICE '✅ Admin existe déjà dans public.admins';
    ELSE
      RAISE NOTICE '📝 Création de l''admin dans public.admins...';
      -- Créer l'admin
      INSERT INTO public.admins (id, admin_type)
      VALUES (existing_user_id, 'super_admin');
    END IF;
    
    RAISE NOTICE '✅ Admin configuré avec succès!';
  ELSE
    RAISE NOTICE '⚠️  Utilisateur non trouvé dans auth.users';
    RAISE NOTICE '';
    RAISE NOTICE '==========================================';
    RAISE NOTICE '📝 CRÉEZ L''UTILISATEUR D''ABORD';
    RAISE NOTICE '==========================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Étapes :';
    RAISE NOTICE '1. Allez dans Supabase Dashboard';
    RAISE NOTICE '2. Authentication > Users > Add User';
    RAISE NOTICE '3. Email: admin@smartdelivery.com';
    RAISE NOTICE '4. Password: Admin123!';
    RAISE NOTICE '5. Cochez "Auto Confirm User"';
    RAISE NOTICE '6. Cliquez "Create User"';
    RAISE NOTICE '7. Relancez ce script';
    RAISE NOTICE '';
    RAISE EXCEPTION 'Utilisateur non trouvé dans auth.users. Créez-le d''abord via le Dashboard.';
  END IF;
END $$;

-- Étape 2: Vérifier et afficher le résultat final
SELECT 
  '🎉 VÉRIFICATION FINALE' as status,
  u.email,
  u.role,
  a.admin_type,
  u.created_at,
  CASE 
    WHEN u.role = 'admin' AND a.admin_type = 'super_admin' 
    THEN '✅ Admin configuré correctement'
    ELSE '⚠️  Configuration incomplète'
  END as verification
FROM public.users u
LEFT JOIN public.admins a ON u.id = a.id
WHERE u.email = 'admin@smartdelivery.com';

-- Afficher les identifiants
SELECT 
  '🔐 IDENTIFIANTS DE CONNEXION' as info,
  'Email: admin@smartdelivery.com' as credential,
  'Password: Admin123!' as password;


























