-- ====================================================================
-- SMART DELIVERY GABON - Création de la table drivers (Livreurs/Motos)
-- ====================================================================
-- Ce fichier crée la table drivers pour le suivi GPS des livreurs
-- Exécutez ce script dans votre console Supabase (SQL Editor)
-- ====================================================================

-- Création de la table drivers
CREATE TABLE IF NOT EXISTS public.drivers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    vehicle_number TEXT, -- Numéro de la moto
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    last_update TIMESTAMPTZ DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true,
    current_package_id UUID REFERENCES public.packages(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- Index pour améliorer les performances
-- ====================================================================

CREATE INDEX IF NOT EXISTS idx_drivers_phone 
    ON public.drivers(phone);

CREATE INDEX IF NOT EXISTS idx_drivers_active 
    ON public.drivers(is_active) WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_drivers_last_update 
    ON public.drivers(last_update DESC);

-- ====================================================================
-- Row Level Security (RLS)
-- ====================================================================

ALTER TABLE public.drivers ENABLE ROW LEVEL SECURITY;

-- Politique de lecture : accès public pour voir les livreurs actifs
CREATE POLICY "Allow public read access to active drivers" ON public.drivers
    FOR SELECT
    USING (is_active = true);

-- Politique d'écriture : seulement les admins peuvent modifier
-- Note: Vous devrez créer une fonction pour vérifier si l'utilisateur est admin
CREATE POLICY "Allow admin write access" ON public.drivers
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- ====================================================================
-- Fonction pour mettre à jour automatiquement updated_at
-- ====================================================================

CREATE OR REPLACE FUNCTION update_drivers_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_drivers_updated_at
    BEFORE UPDATE ON public.drivers
    FOR EACH ROW
    EXECUTE FUNCTION update_drivers_updated_at();

-- ====================================================================
-- Exemple d'insertion d'un livreur de test
-- ====================================================================

-- INSERT INTO public.drivers (name, phone, vehicle_number, latitude, longitude, is_active)
-- VALUES 
--     ('Jean Moto', '+24177123456', 'MOTO-001', 0.3921, 9.4536, true),
--     ('Pierre Livreur', '+24177234567', 'MOTO-002', 0.3921, 9.4536, true);

-- ====================================================================
-- Notes importantes
-- ====================================================================
-- 1. Les coordonnées GPS sont pour Libreville, Gabon (exemple)
-- 2. Vous devrez mettre à jour les positions en temps réel depuis l'application
-- 3. La colonne current_package_id lie le livreur au colis qu'il livre actuellement
-- 4. Les politiques RLS peuvent être ajustées selon vos besoins de sécurité
-- ====================================================================


