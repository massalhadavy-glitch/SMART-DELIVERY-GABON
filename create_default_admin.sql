-- Script pour créer un admin par défaut dans Supabase
-- À exécuter dans l'éditeur SQL de Supabase

-- IMPORTANT: Créez d'abord l'utilisateur via l'interface Supabase Auth
-- Email: admin@smartdelivery.com
-- Password: Admin123!

-- Puis exécutez cette requête pour l'ajouter comme admin

-- Insérer l'admin dans la table (remplacez 'USER_ID' par l'UUID de l'utilisateur)
INSERT INTO admins (id, role)
SELECT id, 'admin'
FROM auth.users
WHERE email = 'admin@smartdelivery.com'
ON CONFLICT (id) DO UPDATE SET role = 'admin';

-- Vérifier que l'admin a été créé
SELECT 
  u.email,
  a.role,
  a.created_at
FROM auth.users u
JOIN admins a ON u.id = a.id
WHERE a.role = 'admin';






































