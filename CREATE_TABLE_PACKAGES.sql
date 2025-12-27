-- ====================================================================
-- SMART DELIVERY GABON - Création de la table packages
-- ====================================================================
-- Ce fichier crée la table packages nécessaire pour l'application
-- Exécutez ce script dans votre console Supabase (SQL Editor)
-- ====================================================================

-- Création de la table packages
CREATE TABLE IF NOT EXISTS public.packages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    tracking_number TEXT UNIQUE NOT NULL,
    sender_name TEXT NOT NULL,
    sender_phone TEXT NOT NULL,
    recipient_name TEXT NOT NULL,
    recipient_phone TEXT NOT NULL,
    pickup_address TEXT NOT NULL,
    destination_address TEXT NOT NULL,
    package_type TEXT NOT NULL,
    delivery_type TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'En attente de collecte',
    cost NUMERIC(10, 2) NOT NULL,
    client_phone_number TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- Index pour améliorer les performances
-- ====================================================================

CREATE INDEX IF NOT EXISTS idx_packages_tracking_number 
    ON public.packages(tracking_number);

CREATE INDEX IF NOT EXISTS idx_packages_status 
    ON public.packages(status);

CREATE INDEX IF NOT EXISTS idx_packages_created_at 
    ON public.packages(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_packages_client_phone 
    ON public.packages(client_phone_number);

-- ====================================================================
-- Row Level Security (RLS)
-- ====================================================================

ALTER TABLE public.packages ENABLE ROW LEVEL SECURITY;

-- Politique de lecture : accès public
CREATE POLICY "Allow public read access" ON public.packages
    FOR SELECT
    USING (true);

-- Politique d'insertion : accès public
CREATE POLICY "Allow public insert access" ON public.packages
    FOR INSERT
    WITH CHECK (true);

-- Politique de mise à jour : accès public
CREATE POLICY "Allow public update access" ON public.packages
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- Politique de suppression : accès public (à restreindre en production)
CREATE POLICY "Allow public delete access" ON public.packages
    FOR DELETE
    USING (true);

-- ====================================================================
-- Trigger pour mettre à jour automatiquement updated_at
-- ====================================================================

-- Fonction de mise à jour
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger sur la table packages
CREATE TRIGGER update_packages_updated_at
    BEFORE UPDATE ON public.packages
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ====================================================================
-- Commentaires sur la table et les colonnes
-- ====================================================================

COMMENT ON TABLE public.packages IS 'Table contenant tous les colis de Smart Delivery Gabon';

COMMENT ON COLUMN public.packages.id IS 'Identifiant unique du colis (UUID)';
COMMENT ON COLUMN public.packages.tracking_number IS 'Numéro de suivi unique (format: SD + date/heure)';
COMMENT ON COLUMN public.packages.sender_name IS 'Nom de l''expéditeur';
COMMENT ON COLUMN public.packages.sender_phone IS 'Numéro de téléphone de l''expéditeur';
COMMENT ON COLUMN public.packages.recipient_name IS 'Nom du destinataire';
COMMENT ON COLUMN public.packages.recipient_phone IS 'Numéro de téléphone du destinataire';
COMMENT ON COLUMN public.packages.pickup_address IS 'Adresse de ramassage du colis';
COMMENT ON COLUMN public.packages.destination_address IS 'Adresse de destination du colis';
COMMENT ON COLUMN public.packages.package_type IS 'Type de colis (Documents, Petit colis, etc.)';
COMMENT ON COLUMN public.packages.delivery_type IS 'Type de livraison (Express 2H-4H ou Standard -48H)';
COMMENT ON COLUMN public.packages.status IS 'Statut actuel du colis';
COMMENT ON COLUMN public.packages.cost IS 'Coût de la livraison en FCFA';
COMMENT ON COLUMN public.packages.client_phone_number IS 'Numéro de téléphone du client pour contact';
COMMENT ON COLUMN public.packages.created_at IS 'Date et heure de création du colis';
COMMENT ON COLUMN public.packages.updated_at IS 'Date et heure de dernière mise à jour';

-- ====================================================================
-- Vérification
-- ====================================================================

-- Afficher la structure de la table
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'packages'
ORDER BY ordinal_position;

-- Message de confirmation
DO $$
BEGIN
    RAISE NOTICE 'Table packages créée avec succès !';
    RAISE NOTICE 'Structure de la table vérifiée.';
    RAISE NOTICE 'Vous pouvez maintenant utiliser l''application Smart Delivery.';
END $$;





































