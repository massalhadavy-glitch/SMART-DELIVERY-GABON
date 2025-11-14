-- Migration pour créer la table des utilisateurs avec rôles
-- Ce script crée la structure pour gérer les utilisateurs et les admins

-- ============================================
-- 1. Création de la table users (profiles)
-- ============================================
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  phone TEXT,
  full_name TEXT,
  role TEXT NOT NULL DEFAULT 'user', -- 'user', 'admin', 'driver'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);

-- ============================================
-- 2. Création de la table admins (hérite de users)
-- ============================================
CREATE TABLE IF NOT EXISTS public.admins (
  id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  admin_type TEXT DEFAULT 'super_admin', -- 'super_admin', 'admin', 'moderator'
  permissions JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 3. Fonction pour synchroniser auth.users avec public.users
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, role)
  VALUES (
    NEW.id,
    NEW.email,
    'user' -- Par défaut, les nouveaux utilisateurs sont des users
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger pour créer automatiquement un profil utilisateur
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- 4. Fonction pour créer un admin
-- ============================================
CREATE OR REPLACE FUNCTION public.create_admin(
  user_email TEXT,
  admin_role TEXT DEFAULT 'super_admin'
)
RETURNS void AS $$
DECLARE
  user_id UUID;
BEGIN
  -- Trouver l'ID de l'utilisateur par email
  SELECT id INTO user_id FROM auth.users WHERE email = user_email;
  
  IF user_id IS NULL THEN
    RAISE EXCEPTION 'Utilisateur non trouvé avec email: %', user_email;
  END IF;
  
  -- Mettre à jour le rôle dans users
  UPDATE public.users
  SET role = 'admin', updated_at = NOW()
  WHERE id = user_id;
  
  -- Insérer dans admins
  INSERT INTO public.admins (id, admin_type)
  VALUES (user_id, admin_role)
  ON CONFLICT (id) DO UPDATE 
    SET admin_type = admin_role, 
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 5. Fonction pour vérifier si un utilisateur est admin
-- ============================================
CREATE OR REPLACE FUNCTION public.is_user_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.users 
    WHERE id = user_id AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 6. Row Level Security (RLS)
-- ============================================

-- Users table policies
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Politique: Les utilisateurs peuvent voir leur propre profil
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT
  USING (auth.uid() = id);

-- Politique: Les utilisateurs peuvent mettre à jour leur propre profil
CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Politique: Tous les utilisateurs authentifiés peuvent voir les profils publics
CREATE POLICY "Authenticated users can view public profiles" ON public.users
  FOR SELECT
  USING (auth.role() = 'authenticated');

-- ============================================
-- 7. Admins table policies
-- ============================================
ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;

-- Politique: Seuls les admins peuvent voir les admins
CREATE POLICY "Admins can view admins" ON public.admins
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Politique: Seuls les super admins peuvent créer des admins
CREATE POLICY "Super admins can insert admins" ON public.admins
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.admins 
      WHERE id = auth.uid() AND admin_type = 'super_admin'
    )
  );

-- ============================================
-- 8. Créer l'admin par défaut
-- ============================================
-- Note: Exécutez cette partie après avoir créé l'utilisateur dans Supabase Auth
-- Email: admin@smartdelivery.com
-- Password: Admin123! (CHANGEZ-LE après la première connexion!)

-- Pour créer l'admin, connectez-vous à Supabase Dashboard:
-- 1. Authentication > Users > Add User
-- 2. Email: admin@smartdelivery.com
-- 3. Password: Admin123!
-- 4. Auto Confirm User: ✅
-- 5. Puis exécutez cette requête:

/*
SELECT public.create_admin('admin@smartdelivery.com', 'super_admin');
*/

-- ============================================
-- 9. Vérification des données
-- ============================================
-- Pour vérifier que tout fonctionne, exécutez:
/*
SELECT 
  u.id,
  u.email,
  u.role,
  a.admin_type,
  u.created_at
FROM public.users u
LEFT JOIN public.admins a ON u.id = a.id
WHERE u.role = 'admin';
*/
