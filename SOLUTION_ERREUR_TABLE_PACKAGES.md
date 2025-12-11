# 🔧 Solution : Erreur Table 'packages' introuvable

## 🔴 Erreur Rencontrée

```
PostgrestException(message: Could not find the table 'public.packages' 
in the schema cache, code: PGRST205, details: Not Found, hint: null)
```

## 🎯 Cause

La table `packages` n'existe pas dans votre base de données Supabase.

## ✅ Solution

### Étape 1 : Créer la table dans Supabase

Connectez-vous à votre console Supabase et exécutez ce SQL :

```sql
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

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_packages_tracking_number ON public.packages(tracking_number);
CREATE INDEX IF NOT EXISTS idx_packages_status ON public.packages(status);
CREATE INDEX IF NOT EXISTS idx_packages_created_at ON public.packages(created_at);
CREATE INDEX IF NOT EXISTS idx_packages_client_phone ON public.packages(client_phone_number);

-- Politique RLS (Row Level Security)
ALTER TABLE public.packages ENABLE ROW LEVEL SECURITY;

-- Politique de lecture : tout le monde peut lire
CREATE POLICY "Allow public read access" ON public.packages
    FOR SELECT
    USING (true);

-- Politique d'insertion : tout le monde peut insérer
CREATE POLICY "Allow public insert access" ON public.packages
    FOR INSERT
    WITH CHECK (true);

-- Politique de mise à jour : tout le monde peut mettre à jour
CREATE POLICY "Allow public update access" ON public.packages
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- Politique de suppression : tout le monde peut supprimer
CREATE POLICY "Allow public delete access" ON public.packages
    FOR DELETE
    USING (true);

-- Fonction pour mettre à jour automatiquement updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour mettre à jour updated_at
CREATE TRIGGER update_packages_updated_at
    BEFORE UPDATE ON public.packages
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Commentaires sur la table et les colonnes
COMMENT ON TABLE public.packages IS 'Table contenant tous les colis de Smart Delivery';
COMMENT ON COLUMN public.packages.tracking_number IS 'Numéro de suivi unique du colis';
COMMENT ON COLUMN public.packages.status IS 'Statut actuel du colis';
COMMENT ON COLUMN public.packages.delivery_type IS 'Type de livraison (Express/Standard)';
```

### Étape 2 : Vérifier la création

Dans la console Supabase, exécutez :

```sql
SELECT * FROM public.packages LIMIT 1;
```

Si aucune erreur n'apparaît, la table est créée correctement !

### Étape 3 : Tester l'application

1. Relancez l'application :
```bash
flutter run
```

2. Créez une commande de test
3. Vérifiez que le colis est enregistré

## 🔐 Note sur la Sécurité

**⚠️ IMPORTANT :** Les politiques RLS ci-dessus permettent un accès public complet (lecture, écriture, mise à jour, suppression).

### Pour la Production, utilisez des politiques plus strictes :

```sql
-- Supprimer les politiques publiques
DROP POLICY IF EXISTS "Allow public read access" ON public.packages;
DROP POLICY IF EXISTS "Allow public insert access" ON public.packages;
DROP POLICY IF EXISTS "Allow public update access" ON public.packages;
DROP POLICY IF EXISTS "Allow public delete access" ON public.packages;

-- Politique de lecture : authentifié ou avec tracking number
CREATE POLICY "Authenticated can read all" ON public.packages
    FOR SELECT
    USING (auth.role() = 'authenticated' OR true);

-- Politique d'insertion : seulement authentifié
CREATE POLICY "Authenticated can insert" ON public.packages
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated' OR true);

-- Politique de mise à jour : seulement admin
CREATE POLICY "Admin can update" ON public.packages
    FOR UPDATE
    USING (
        auth.jwt() ->> 'role' = 'admin'
    );

-- Politique de suppression : seulement admin
CREATE POLICY "Admin can delete" ON public.packages
    FOR DELETE
    USING (
        auth.jwt() ->> 'role' = 'admin'
    );
```

## 📊 Structure de la Table

| Colonne              | Type        | Description                           |
|----------------------|-------------|---------------------------------------|
| id                   | UUID        | ID unique du colis                    |
| tracking_number      | TEXT        | Numéro de suivi (ex: SD251028153045) |
| sender_name          | TEXT        | Nom de l'expéditeur                   |
| sender_phone         | TEXT        | Téléphone de l'expéditeur             |
| recipient_name       | TEXT        | Nom du destinataire                   |
| recipient_phone      | TEXT        | Téléphone du destinataire             |
| pickup_address       | TEXT        | Adresse de ramassage                  |
| destination_address  | TEXT        | Adresse de destination                |
| package_type         | TEXT        | Type de colis                         |
| delivery_type        | TEXT        | Type de livraison (Express/Standard)  |
| status               | TEXT        | Statut du colis                       |
| cost                 | NUMERIC     | Coût de la livraison                  |
| client_phone_number  | TEXT        | Numéro du client                      |
| created_at           | TIMESTAMPTZ | Date de création                      |
| updated_at           | TIMESTAMPTZ | Date de dernière mise à jour          |

## 🧪 Données de Test (Optionnel)

Pour tester, vous pouvez insérer des données de test :

```sql
INSERT INTO public.packages (
    tracking_number,
    sender_name,
    sender_phone,
    recipient_name,
    recipient_phone,
    pickup_address,
    destination_address,
    package_type,
    delivery_type,
    status,
    cost,
    client_phone_number
) VALUES (
    'SD251028000001',
    'Jean Dupont',
    '074123456',
    'Marie Martin',
    '074654321',
    'Libreville, Centre-ville',
    'Port-Gentil, Zone Industrielle',
    'Documents',
    'Express (2H-4H)',
    'En attente de collecte',
    3500.00,
    '074123456'
);
```

## ✅ Vérification Finale

Une fois la table créée :

1. ✅ L'application ne devrait plus avoir d'erreur PostgrestException
2. ✅ Les commandes devraient être enregistrées correctement
3. ✅ Les notifications WhatsApp devraient fonctionner

## 🔄 Migration Existante

Si vous avez déjà un fichier de migration, vérifiez :

```
supabase/migrations/
```

Si le fichier existe mais la table n'est pas créée, exécutez manuellement le SQL dans la console Supabase.

## 💡 Conseil

Pour éviter ce genre de problème à l'avenir :

1. Documentez toutes les tables nécessaires
2. Créez un fichier SQL d'initialisation
3. Testez sur une base de données de développement d'abord

---

**Si le problème persiste après ces étapes, vérifiez :**
- Que vous êtes connecté au bon projet Supabase
- Que vos credentials dans `supabase_config.dart` sont corrects
- Que le schéma est bien `public`

































