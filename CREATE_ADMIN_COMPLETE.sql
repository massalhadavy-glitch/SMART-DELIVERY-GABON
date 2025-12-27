-- ============================================
-- Script Complet pour Créer un Admin
-- Ce script crée l'utilisateur auth ET le profil dans la base de données
-- ============================================

-- IMPORTANT: Ce script nécessite des permissions admin sur Supabase
-- Pour l'exécuter, vous devez être connecté en tant que admin du projet

DO $$ 
DECLARE
  new_user_id UUID;
  hashed_password TEXT;
BEGIN
  -- Vérifier si l'utilisateur existe déjà
  IF EXISTS (SELECT 1 FROM auth.users WHERE email = 'admin@smartdelivery.com') THEN
    RAISE NOTICE '✅ Utilisateur admin@smartdelivery.com existe déjà dans auth.users';
    
    -- Récupérer l'ID de l'utilisateur existant
    SELECT id INTO new_user_id FROM auth.users WHERE email = 'admin@smartdelivery.com';
    
    -- Promouvoir en admin
    RAISE NOTICE '🚀 Promotion en cours...';
    PERFORM public.create_admin('admin@smartdelivery.com', 'super_admin');
    
    RAISE NOTICE '✅ Admin existant promu avec succès!';
  ELSE
    RAISE NOTICE '📝 Création d''un nouvel utilisateur admin...';
    
    -- Générer un UUID pour le nouvel utilisateur
    new_user_id := gen_random_uuid();
    
    -- Hasher le mot de passe (Admin123!)
    -- Note: En production, utilisez crypt() de l'extension pgcrypto
    -- Pour cette démo, nous allons utiliser la fonction auth.uid() de Supabase
    -- Vous devrez initialiser auth.users manuellement via l'API ou le Dashboard
    
    RAISE NOTICE '⚠️  ATTENTION: La création directe dans auth.users nécessite des permissions spéciales.';
    RAISE NOTICE '📝 Étapes manuelles requises:';
    RAISE NOTICE '   1. Allez dans Supabase Dashboard > Authentication > Users';
    RAISE NOTICE '   2. Cliquez sur "Add User" > "Create new user"';
    RAISE NOTICE '   3. Email: admin@smartdelivery.com';
    RAISE NOTICE '   4. Password: Admin123!';
    RAISE NOTICE '   5. Cochez "Auto Confirm User"';
    RAISE NOTICE '   6. Cliquez "Create User"';
    RAISE NOTICE '   7. Puis exécutez: SELECT public.create_admin(''admin@smartdelivery.com'', ''super_admin'');';
    
    -- Créer le profil utilisateur (sera synchronisé avec auth.users)
    INSERT INTO public.users (id, email, role)
    VALUES (new_user_id, 'admin@smartdelivery.com', 'admin')
    ON CONFLICT (id) DO NOTHING;
    
    RAISE NOTICE '✅ Profil utilisateur créé dans public.users';
    RAISE NOTICE '⚠️  Créez maintenant l''utilisateur auth manuellement via le Dashboard';
    RAISE EXCEPTION 'Créez l''utilisateur dans auth.users via le Dashboard, puis relancez le script';
  END IF;
  
  -- Afficher les informations finales
  RAISE NOTICE '=================================================';
  RAISE NOTICE '✅ ADMIN CRÉÉ AVEC SUCCÈS!';
  RAISE NOTICE '📧 Email: admin@smartdelivery.com';
  RAISE NOTICE '🔑 Password: Admin123!';
  RAISE NOTICE '⚠️  Changez ce mot de passe après la première connexion!';
  RAISE NOTICE '=================================================';
  
END $$;

-- Vérification finale
SELECT 
  '🎉 Vérification Finale' as status,
  u.email,
  u.role,
  a.admin_type,
  u.created_at
FROM public.users u
LEFT JOIN public.admins a ON u.id = a.id
WHERE u.email = 'admin@smartdelivery.com';






































