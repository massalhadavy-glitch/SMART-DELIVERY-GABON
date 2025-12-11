-- ============================================
-- 🔧 CORRECTION DES PERMISSIONS RLS - TABLE PACKAGES
-- ============================================
-- Ce script corrige les politiques RLS pour permettre
-- aux administrateurs de mettre à jour le statut des colis
-- sur la version web

-- ============================================
-- ÉTAPE 1: Vérifier l'état actuel des politiques
-- ============================================
SELECT 
  '=== ÉTAT ACTUEL DES POLITIQUES PACKAGES ===' as info,
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'packages'
ORDER BY policyname;

-- ============================================
-- ÉTAPE 2: Supprimer les anciennes politiques de mise à jour
-- ============================================
DROP POLICY IF EXISTS "Allow public update access" ON public.packages;
DROP POLICY IF EXISTS "Admin can update" ON public.packages;
DROP POLICY IF EXISTS "Authenticated can update" ON public.packages;
DROP POLICY IF EXISTS "Mise à jour packages" ON public.packages;

-- ============================================
-- ÉTAPE 3: Créer une politique de mise à jour pour les admins
-- ============================================

-- Politique: Les administrateurs peuvent mettre à jour tous les colis
CREATE POLICY "Admins can update packages"
ON public.packages
FOR UPDATE
TO authenticated
USING (
  -- Vérifier que l'utilisateur est dans la table users avec role = 'admin'
  EXISTS (
    SELECT 1 FROM public.users 
    WHERE id = auth.uid() AND role = 'admin'
  )
  -- OU vérifier dans la table admins
  OR EXISTS (
    SELECT 1 FROM public.admins 
    WHERE id = auth.uid()
  )
)
WITH CHECK (
  -- Même vérification pour WITH CHECK
  EXISTS (
    SELECT 1 FROM public.users 
    WHERE id = auth.uid() AND role = 'admin'
  )
  OR EXISTS (
    SELECT 1 FROM public.admins 
    WHERE id = auth.uid()
  )
);

-- ============================================
-- ÉTAPE 4: S'assurer que RLS est activé
-- ============================================
ALTER TABLE public.packages ENABLE ROW LEVEL SECURITY;

-- ============================================
-- ÉTAPE 5: Vérifier les politiques créées
-- ============================================
SELECT 
  '=== POLITIQUES APRÈS CORRECTION ===' as info,
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'packages'
ORDER BY policyname;

-- ============================================
-- ÉTAPE 6: Test de diagnostic
-- ============================================

-- Vérifier que RLS est activé
SELECT 
  '=== ÉTAT RLS ===' as info,
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename = 'packages' AND schemaname = 'public';

-- Compter les politiques
SELECT 
  '=== NOMBRE DE POLITIQUES ===' as info,
  COUNT(*) as nombre_politiques
FROM pg_policies
WHERE tablename = 'packages';

-- ============================================
-- ÉTAPE 7: Informations de diagnostic
-- ============================================

DO $$
DECLARE
  rls_enabled BOOLEAN;
  policy_count INTEGER;
  update_policy_exists BOOLEAN;
BEGIN
  -- Vérifier RLS
  SELECT rowsecurity INTO rls_enabled 
  FROM pg_tables 
  WHERE tablename = 'packages' AND schemaname = 'public';
  
  -- Compter les politiques
  SELECT COUNT(*) INTO policy_count 
  FROM pg_policies 
  WHERE tablename = 'packages';
  
  -- Vérifier si la politique de mise à jour existe
  SELECT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'packages' 
    AND cmd = 'UPDATE'
    AND policyname = 'Admins can update packages'
  ) INTO update_policy_exists;
  
  RAISE NOTICE '═══════════════════════════════════════════';
  RAISE NOTICE '🔍 DIAGNOSTIC RLS - TABLE PACKAGES';
  RAISE NOTICE '═══════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '🔒 RLS activé: %', rls_enabled;
  RAISE NOTICE '📋 Nombre de politiques: %', policy_count;
  RAISE NOTICE '✅ Politique UPDATE admin existe: %', update_policy_exists;
  RAISE NOTICE '';
  
  IF NOT rls_enabled THEN
    RAISE NOTICE '⚠️  ATTENTION: RLS n''est pas activé!';
  ELSE
    RAISE NOTICE '✅ RLS est activé';
  END IF;
  
  IF NOT update_policy_exists THEN
    RAISE NOTICE '⚠️  ATTENTION: La politique de mise à jour admin n''existe pas!';
  ELSE
    RAISE NOTICE '✅ Politique de mise à jour admin créée';
  END IF;
  
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════';
  RAISE NOTICE '✅ CORRECTION TERMINÉE';
  RAISE NOTICE '═══════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '🧪 Testez maintenant la mise à jour du statut dans l''application web';
  RAISE NOTICE '';
END $$;

-- ============================================
-- INSTRUCTIONS FINALES
-- ============================================

/*
✅ Ce script a:
1. Vérifié l'état actuel des politiques
2. Supprimé les anciennes politiques de mise à jour
3. Créé une nouvelle politique permettant aux admins de mettre à jour
4. Vérifié que RLS est activé
5. Effectué des tests de diagnostic

📝 POLITIQUE CRÉÉE:

"Admins can update packages" (UPDATE)
   - Permet aux utilisateurs authentifiés qui sont admin de mettre à jour les colis
   - Vérifie dans la table users (role = 'admin') OU dans la table admins
   - Fonctionne pour les mises à jour de statut

🔍 VÉRIFICATIONS:
- RLS doit être activé sur la table packages
- La politique "Admins can update packages" doit exister
- L'utilisateur doit être authentifié et avoir role = 'admin' dans users

🧪 POUR TESTER:
1. Connectez-vous en tant qu'admin dans l'application web
2. Essayez de mettre à jour le statut d'un colis
3. Vérifiez les logs dans la console du navigateur

❌ SI ÇA NE FONCTIONNE TOUJOURS PAS:

1. Vérifiez que l'utilisateur est bien admin:
   SELECT id, email, role FROM public.users WHERE email = 'votre_email@example.com';

2. Vérifiez que l'utilisateur est authentifié:
   - Dans l'application, vérifiez que vous êtes bien connecté
   - Vérifiez la session Supabase dans les DevTools du navigateur

3. Testez manuellement la mise à jour:
   UPDATE public.packages 
   SET status = 'Test', updated_at = NOW() 
   WHERE tracking_number = 'SD...' 
   AND EXISTS (
     SELECT 1 FROM public.users 
     WHERE id = auth.uid() AND role = 'admin'
   );
*/

