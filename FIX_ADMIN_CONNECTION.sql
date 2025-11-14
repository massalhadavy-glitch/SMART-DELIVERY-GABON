-- ============================================
-- 🔧 SCRIPT DE CORRECTION - CONNEXION ADMIN
-- ============================================
-- Ce script corrige tous les problèmes de connexion admin
-- Exécutez ce script dans le SQL Editor de Supabase

-- ============================================
-- ÉTAPE 1: Vérifier/Créer les tables
-- ============================================

-- Table users (si elle n'existe pas)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  phone TEXT,
  full_name TEXT,
  role TEXT NOT NULL DEFAULT 'user',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);

-- Table admins (si elle n'existe pas)
CREATE TABLE IF NOT EXISTS public.admins (
  id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  admin_type TEXT DEFAULT 'super_admin',
  permissions JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- ÉTAPE 2: Corriger les Politiques RLS
-- ============================================

-- Désactiver temporairement RLS pour permettre la synchronisation
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.admins DISABLE ROW LEVEL SECURITY;

-- Supprimer toutes les anciennes politiques
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Authenticated users can view public profiles" ON public.users;
DROP POLICY IF EXISTS "Admins can view admins" ON public.admins;
DROP POLICY IF EXISTS "Super admins can insert admins" ON public.admins;

-- Créer de nouvelles politiques plus permissives
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;

-- Politique: Les utilisateurs authentifiés peuvent lire tous les profils
CREATE POLICY "Authenticated users can read all users" 
ON public.users FOR SELECT
USING (auth.role() = 'authenticated');

-- Politique: Les utilisateurs peuvent mettre à jour leur propre profil
CREATE POLICY "Users can update own profile" 
ON public.users FOR UPDATE
USING (auth.uid() = id);

-- Politique: Les utilisateurs authentifiés peuvent lire les admins (pour vérification)
CREATE POLICY "Authenticated users can read admins" 
ON public.admins FOR SELECT
USING (auth.role() = 'authenticated');

-- Politique: Les admins peuvent tout faire sur admins
CREATE POLICY "Admins can manage admins" 
ON public.admins FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.users 
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- ============================================
-- ÉTAPE 3: Créer/Recréer le trigger de synchronisation
-- ============================================

-- Fonction pour synchroniser auth.users avec public.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, role)
  VALUES (
    NEW.id,
    NEW.email,
    'user'
  )
  ON CONFLICT (id) 
  DO UPDATE SET 
    email = EXCLUDED.email,
    updated_at = NOW();
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Supprimer l'ancien trigger s'il existe
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Créer le nouveau trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW 
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- ÉTAPE 4: Fonction pour créer un admin
-- ============================================

CREATE OR REPLACE FUNCTION public.create_admin(
  user_email TEXT,
  admin_role TEXT DEFAULT 'super_admin'
)
RETURNS TEXT AS $$
DECLARE
  user_id UUID;
  result TEXT;
BEGIN
  -- Trouver l'ID de l'utilisateur par email dans auth.users
  SELECT id INTO user_id FROM auth.users WHERE email = user_email;
  
  IF user_id IS NULL THEN
    RETURN '❌ Erreur: Utilisateur non trouvé avec email: ' || user_email;
  END IF;
  
  -- S'assurer que l'utilisateur existe dans public.users
  INSERT INTO public.users (id, email, role)
  VALUES (user_id, user_email, 'admin')
  ON CONFLICT (id) 
  DO UPDATE SET 
    role = 'admin', 
    updated_at = NOW();
  
  -- Insérer ou mettre à jour dans admins
  INSERT INTO public.admins (id, admin_type)
  VALUES (user_id, admin_role)
  ON CONFLICT (id) 
  DO UPDATE SET 
    admin_type = admin_role, 
    updated_at = NOW();
  
  result := '✅ Utilisateur ' || user_email || ' promu en admin avec succès!';
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- ÉTAPE 5: Synchroniser les utilisateurs existants
-- ============================================

-- Synchroniser tous les utilisateurs de auth.users vers public.users
INSERT INTO public.users (id, email, role)
SELECT 
  au.id,
  au.email,
  COALESCE(pu.role, 'user') as role
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  updated_at = NOW();

-- ============================================
-- ÉTAPE 6: Créer l'admin par défaut
-- ============================================

-- Vérifier si l'utilisateur admin@smartdelivery.com existe
DO $$ 
DECLARE
  admin_exists BOOLEAN;
  user_id UUID;
  result TEXT;
BEGIN
  -- Vérifier dans auth.users
  SELECT EXISTS(SELECT 1 FROM auth.users WHERE email = 'admin@smartdelivery.com')
  INTO admin_exists;
  
  IF NOT admin_exists THEN
    RAISE NOTICE '⚠️  L''utilisateur admin@smartdelivery.com n''existe pas encore dans auth.users';
    RAISE NOTICE '📝 Veuillez créer l''utilisateur via le Dashboard Supabase:';
    RAISE NOTICE '   1. Authentication > Users > Add User';
    RAISE NOTICE '   2. Email: admin@smartdelivery.com';
    RAISE NOTICE '   3. Password: Admin123!';
    RAISE NOTICE '   4. ✅ Auto Confirm User';
    RAISE NOTICE '   5. Puis relancez ce script';
  ELSE
    -- Promouvoir en admin
    SELECT public.create_admin('admin@smartdelivery.com', 'super_admin')
    INTO result;
    
    RAISE NOTICE '%', result;
    RAISE NOTICE '📧 Email: admin@smartdelivery.com';
    RAISE NOTICE '🔑 Password: Admin123! (changez-le après connexion)';
  END IF;
END $$;

-- ============================================
-- ÉTAPE 7: Vérification finale
-- ============================================

SELECT 
  '=== VÉRIFICATION ===' as check_type,
  'Table users' as item,
  COUNT(*)::TEXT as count
FROM public.users
UNION ALL
SELECT 
  '=== VÉRIFICATION ===',
  'Admins',
  COUNT(*)::TEXT
FROM public.admins
UNION ALL
SELECT 
  '=== VÉRIFICATION ===',
  'Utilisateurs dans auth.users',
  COUNT(*)::TEXT
FROM auth.users;

-- Afficher les admins existants
SELECT 
  '🎉 ADMIN CONFIGURÉ' as status,
  u.email,
  u.role,
  a.admin_type,
  u.created_at
FROM public.users u
LEFT JOIN public.admins a ON u.id = a.id
WHERE u.role = 'admin'
ORDER BY u.created_at DESC;

-- ============================================
-- 📝 INSTRUCTIONS FINALES
-- ============================================

/*
✅ Ce script a:
1. Créé/vérifié les tables users et admins
2. Corrigé les politiques RLS
3. Créé le trigger de synchronisation
4. Synchronisé les utilisateurs existants
5. Promu admin@smartdelivery.com en admin (s'il existe)

📧 Identifiants de connexion:
   Email: admin@smartdelivery.com
   Password: Admin123!

⚠️ Si l'utilisateur n'existe pas encore:
1. Allez dans Supabase Dashboard
2. Authentication > Users > Add User
3. Créez l'utilisateur avec l'email ci-dessus
4. Relancez ce script

🧪 Pour tester:
SELECT public.create_admin('admin@smartdelivery.com', 'super_admin');

🔍 Pour vérifier:
SELECT 
  u.email, 
  u.role, 
  a.admin_type 
FROM public.users u 
LEFT JOIN public.admins a ON u.id = a.id 
WHERE u.email = 'admin@smartdelivery.com';
*/

