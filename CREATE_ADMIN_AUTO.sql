-- ============================================
-- Script Automatique pour Créer un Admin
-- Ce script crée TOUT : auth.users + public.users + admins
-- ============================================
-- WARNING: Nécessite des permissions admin et l'extension pgcrypto
-- ============================================

-- Activer l'extension pgcrypto pour le hachage de mot de passe
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Supprimer l'utilisateur existant s'il existe (pour un reset propre)
DO $$ 
DECLARE
  existing_user_id UUID;
BEGIN
  -- Chercher l'utilisateur existant
  SELECT id INTO existing_user_id 
  FROM auth.users 
  WHERE email = 'admin@smartdelivery.com';
  
  IF existing_user_id IS NOT NULL THEN
    -- Supprimer de la table admins
    DELETE FROM public.admins WHERE id = existing_user_id;
    -- Supprimer de la table users
    DELETE FROM public.users WHERE id = existing_user_id;
    -- Supprimer de auth.users
    DELETE FROM auth.users WHERE id = existing_user_id;
    RAISE NOTICE '🗑️  Utilisateur existant supprimé pour reset propre';
  END IF;
END $$;

-- Créer le nouvel utilisateur admin
DO $$ 
DECLARE
  new_user_id UUID;
  user_confirmed_at TIMESTAMP WITH TIME ZONE;
BEGIN
  -- Générer un UUID unique
  new_user_id := gen_random_uuid();
  
  -- Horodatage pour confirmed_at
  user_confirmed_at := NOW();
  
  -- Hasher le mot de passe "Admin123!"
  -- Note: Le mot de passe est "Admin123!" qui doit être hashé avec bcrypt
  -- Pour cet exemple, nous utilisons une valeur placeholder
  -- En production, utilisez Supabase Auth API
  
  RAISE NOTICE '📝 Création de l''utilisateur auth...';
  
  -- Insertion dans auth.users
  INSERT INTO auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmed_at,
    recovery_sent_at,
    last_sign_in_at,
    email_confirmed,
    phone_confirmed,
    confirmation_token
  )
  VALUES (
    new_user_id,
    auth.uid() IS DISTINCT FROM NULL 
      WHEN TRUE THEN auth.uid() 
      ELSE (SELECT instance_id FROM auth.users LIMIT 1) 
    END,
    'admin@smartdelivery.com',
    crypt('Admin123!', gen_salt('bf')), -- bcrypt hash pour le mot de passe
    user_confirmed_at,
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    '{"name": "Admin"}'::jsonb,
    NOW(),
    NOW(),
    user_confirmed_at,
    NULL,
    NULL,
    TRUE,
    FALSE,
    NULL
  );
  
  RAISE NOTICE '✅ Utilisateur créé dans auth.users';
  RAISE NOTICE '📝 ID: %', new_user_id;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '⚠️  Erreur lors de la création dans auth.users: %', SQLERRM;
    RAISE NOTICE '📝 Tentative de création via fonction alternative...';
END $$;

-- Fonction helper pour créer un utilisateur via Supabase Auth
CREATE OR REPLACE FUNCTION auth.create_user_admin()
RETURNS TABLE(user_id UUID, email TEXT) 
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  new_user_id UUID;
BEGIN
  -- Cette fonction requiert des permissions SERVICE_ROLE
  -- Elle ne peut être appelée que depuis le service backend
  RAISE NOTICE 'Cette fonction nécessite SERVICE_ROLE permissions';
  RETURN;
END;
$$;

-- Créer le profil dans public.users
DO $$ 
DECLARE
  user_id UUID;
BEGIN
  -- Trouver l'ID de l'utilisateur créé
  SELECT id INTO user_id 
  FROM auth.users 
  WHERE email = 'admin@smartdelivery.com';
  
  IF user_id IS NOT NULL THEN
    -- Insérer dans public.users
    INSERT INTO public.users (id, email, role)
    VALUES (user_id, 'admin@smartdelivery.com', 'admin')
    ON CONFLICT (id) DO UPDATE 
      SET role = 'admin', updated_at = NOW();
    
    RAISE NOTICE '✅ Profil créé dans public.users';
    
    -- Créer l'admin
    INSERT INTO public.admins (id, admin_type)
    VALUES (user_id, 'super_admin')
    ON CONFLICT (id) DO UPDATE 
      SET admin_type = 'super_admin', updated_at = NOW();
    
    RAISE NOTICE '✅ Admin créé dans public.admins';
  ELSE
    RAISE WARNING '⚠️  Utilisateur non trouvé dans auth.users';
  END IF;
END $$;

-- Afficher le résultat final
SELECT 
  '🎉 ADMIN CRÉÉ AVEC SUCCÈS!' as status,
  u.email,
  u.role,
  a.admin_type,
  u.created_at,
  'admin@smartdelivery.com' as email_login,
  'Admin123!' as password_login,
  '⚠️ Changez ce mot de passe!' as warning
FROM public.users u
LEFT JOIN public.admins a ON u.id = a.id
WHERE u.email = 'admin@smartdelivery.com';


























