-- ============================================
-- 🔧 CORRECTION DES PERMISSIONS RLS - TABLE ADMINS
-- ============================================
-- Ce script corrige les politiques RLS pour permettre
-- la lecture de la table admins lors de la connexion

-- ============================================
-- ÉTAPE 1: Désactiver temporairement RLS pour diagnostic
-- ============================================
ALTER TABLE public.admins DISABLE ROW LEVEL SECURITY;

-- ============================================
-- ÉTAPE 2: Supprimer les anciennes politiques
-- ============================================
DROP POLICY IF EXISTS "Admins can view admins" ON public.admins;
DROP POLICY IF EXISTS "Super admins can insert admins" ON public.admins;
DROP POLICY IF EXISTS "Authenticated users can read admins" ON public.admins;
DROP POLICY IF EXISTS "Admins can manage admins" ON public.admins;

-- ============================================
-- ÉTAPE 3: Créer une politique permissive pour la lecture
-- ============================================

-- Politique: Permettre à tous les utilisateurs authentifiés de lire les admins
-- (nécessaire pour que la vérification lors de la connexion fonctionne)
CREATE POLICY "Allow authenticated users to read admins"
ON public.admins
FOR SELECT
TO authenticated
USING (true);

-- Politique: Seuls les super admins peuvent créer des admins
CREATE POLICY "Super admins can insert admins"
ON public.admins
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.admins 
    WHERE id = auth.uid() AND admin_type = 'super_admin'
  )
);

-- Politique: Seuls les super admins peuvent modifier des admins
CREATE POLICY "Super admins can update admins"
ON public.admins
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.admins 
    WHERE id = auth.uid() AND admin_type = 'super_admin'
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.admins 
    WHERE id = auth.uid() AND admin_type = 'super_admin'
  )
);

-- Politique: Seuls les super admins peuvent supprimer des admins
CREATE POLICY "Super admins can delete admins"
ON public.admins
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.admins 
    WHERE id = auth.uid() AND admin_type = 'super_admin'
  )
);

-- ============================================
-- ÉTAPE 4: Réactiver RLS
-- ============================================
ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;

-- ============================================
-- ÉTAPE 5: Vérifier les politiques créées
-- ============================================
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'admins'
ORDER BY policyname;

-- ============================================
-- ÉTAPE 6: Tester l'accès à la table admins
-- ============================================

-- Test 1: Vérifier que la table existe et contient des données
SELECT 
  '=== TEST 1: Contenu de la table admins ===' as test,
  COUNT(*) as nombre_admins
FROM public.admins;

-- Test 2: Afficher tous les admins
SELECT 
  '=== TEST 2: Liste des admins ===' as test,
  a.id,
  au.email,
  a.admin_type,
  a.created_at
FROM public.admins a
JOIN auth.users au ON a.id = au.id
ORDER BY a.created_at DESC;

-- Test 3: Vérifier l'admin spécifique
SELECT 
  '=== TEST 3: Admin admin@smartdelivery.com ===' as test,
  a.id,
  au.email,
  a.admin_type,
  a.permissions,
  a.created_at,
  a.updated_at
FROM public.admins a
JOIN auth.users au ON a.id = au.id
WHERE au.email = 'admin@smartdelivery.com';

-- Test 4: Vérifier que RLS est activé
SELECT 
  '=== TEST 4: État RLS ===' as test,
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename = 'admins';

-- ============================================
-- ÉTAPE 7: Informations de diagnostic
-- ============================================

DO $$
DECLARE
  admin_count INTEGER;
  rls_enabled BOOLEAN;
  policy_count INTEGER;
BEGIN
  -- Compter les admins
  SELECT COUNT(*) INTO admin_count FROM public.admins;
  
  -- Vérifier RLS
  SELECT rowsecurity INTO rls_enabled 
  FROM pg_tables 
  WHERE tablename = 'admins' AND schemaname = 'public';
  
  -- Compter les politiques
  SELECT COUNT(*) INTO policy_count 
  FROM pg_policies 
  WHERE tablename = 'admins';
  
  RAISE NOTICE '═══════════════════════════════════════════';
  RAISE NOTICE '🔍 DIAGNOSTIC RLS - TABLE ADMINS';
  RAISE NOTICE '═══════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '📊 Nombre d''admins: %', admin_count;
  RAISE NOTICE '🔒 RLS activé: %', rls_enabled;
  RAISE NOTICE '📋 Nombre de politiques: %', policy_count;
  RAISE NOTICE '';
  
  IF admin_count = 0 THEN
    RAISE NOTICE '⚠️  ATTENTION: Aucun admin trouvé!';
    RAISE NOTICE '📝 Exécutez: SELECT public.create_admin(''admin@smartdelivery.com'', ''super_admin'');';
  ELSIF admin_count > 0 THEN
    RAISE NOTICE '✅ Admins trouvés dans la base de données';
  END IF;
  
  IF NOT rls_enabled THEN
    RAISE NOTICE '⚠️  ATTENTION: RLS n''est pas activé!';
  ELSE
    RAISE NOTICE '✅ RLS est activé';
  END IF;
  
  IF policy_count < 4 THEN
    RAISE NOTICE '⚠️  ATTENTION: Certaines politiques manquent';
    RAISE NOTICE '📝 Attendu: 4 politiques (SELECT, INSERT, UPDATE, DELETE)';
    RAISE NOTICE '📝 Trouvé: % politiques', policy_count;
  ELSE
    RAISE NOTICE '✅ Toutes les politiques sont en place';
  END IF;
  
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════';
  RAISE NOTICE '✅ CORRECTION TERMINÉE';
  RAISE NOTICE '═══════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '🧪 Testez maintenant la connexion admin dans l''application';
  RAISE NOTICE '📧 Email: admin@smartdelivery.com';
  RAISE NOTICE '🔑 Password: Admin123!';
  RAISE NOTICE '';
END $$;

-- ============================================
-- INSTRUCTIONS FINALES
-- ============================================

/*
✅ Ce script a:
1. Désactivé temporairement RLS pour diagnostic
2. Supprimé les anciennes politiques
3. Créé de nouvelles politiques permissives
4. Réactivé RLS
5. Vérifié que tout fonctionne

📝 POLITIQUES CRÉÉES:

1. "Allow authenticated users to read admins" (SELECT)
   - Permet à tous les utilisateurs authentifiés de lire la table admins
   - Nécessaire pour la vérification lors de la connexion

2. "Super admins can insert admins" (INSERT)
   - Seuls les super_admin peuvent créer de nouveaux admins

3. "Super admins can update admins" (UPDATE)
   - Seuls les super_admin peuvent modifier les admins

4. "Super admins can delete admins" (DELETE)
   - Seuls les super_admin peuvent supprimer les admins

🔍 VÉRIFICATIONS:
- La table admins doit contenir au moins un admin
- RLS doit être activé
- 4 politiques doivent être créées

🧪 POUR TESTER:
1. Relancez l'application Flutter
2. Essayez de vous connecter avec:
   Email: admin@smartdelivery.com
   Password: Admin123!
3. Vérifiez les logs dans la console

❌ SI ÇA NE FONCTIONNE TOUJOURS PAS:

Exécutez cette requête pour diagnostic:
SELECT 
  au.email,
  a.admin_type,
  a.id
FROM auth.users au
LEFT JOIN public.admins a ON au.id = a.id
WHERE au.email = 'admin@smartdelivery.com';

Si la colonne admin_type est NULL, créez l'admin:
SELECT public.create_admin('admin@smartdelivery.com', 'super_admin');
*/

