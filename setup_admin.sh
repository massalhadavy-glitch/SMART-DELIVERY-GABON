#!/bin/bash
# ============================================
# Script Shell pour Créer l'Admin Automatiquement
# ============================================

echo "🚀 Création de l'admin Smart Delivery Gabon"
echo "=========================================="

# Variables
EMAIL="admin@smartdelivery.com"
PASSWORD="Admin123!"
PROJECT_REF=""
SUPABASE_URL=""

echo ""
echo "📝 Veuillez fournir les informations suivantes :"
echo ""

read -p "Project Reference (trouvable dans Settings > API) : " PROJECT_REF
read -p "Supabase URL (ex: https://xxxxx.supabase.co) : " SUPABASE_URL
read -p "Service Role Key (trouvable dans Settings > API) : " SERVICE_KEY

echo ""
echo "=========================================="
echo "📋 Vérification des variables..."
echo "=========================================="

if [ -z "$PROJECT_REF" ] || [ -z "$SUPABASE_URL" ] || [ -z "$SERVICE_KEY" ]; then
    echo "❌ Erreur : Toutes les variables sont requises"
    exit 1
fi

echo "✅ Variables configurées"
echo ""

echo "=========================================="
echo "🔧 Création de l'utilisateur admin..."
echo "=========================================="

# Créer l'utilisateur via l'API Supabase
RESPONSE=$(curl -s -X POST "$SUPABASE_URL/auth/v1/admin/users" \
-H "apikey: $SERVICE_KEY" \
-H "Authorization: Bearer $SERVICE_KEY" \
-H "Content-Type: application/json" \
-d "{
  \"email\": \"$EMAIL\",
  \"password\": \"$PASSWORD\",
  \"email_confirm\": true,
  \"user_metadata\": {
    \"name\": \"Admin\"
  }
}")

# Vérifier si la création a réussi
if echo "$RESPONSE" | grep -q '"id"'; then
    echo "✅ Utilisateur créé avec succès dans auth.users"
    
    # Extraire l'ID de l'utilisateur
    USER_ID=$(echo "$RESPONSE" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
    echo "📝 ID Utilisateur: $USER_ID"
    
    echo ""
    echo "=========================================="
    echo "✅ IDENTIFIANTS DE CONNEXION :"
    echo "=========================================="
    echo "Email: $EMAIL"
    echo "Password: $PASSWORD"
    echo ""
    echo "⚠️  Changez ce mot de passe après la première connexion!"
    echo ""
    
else
    # Vérifier si l'utilisateur existe déjà
    if echo "$RESPONSE" | grep -q "User already registered"; then
        echo "⚠️  Utilisateur existe déjà"
        echo "📝 Récupération de l'ID existant..."
        
        # Récupérer l'ID de l'utilisateur existant
        USER_RESPONSE=$(curl -s -X GET "$SUPABASE_URL/auth/v1/admin/users?email=$EMAIL" \
        -H "apikey: $SERVICE_KEY" \
        -H "Authorization: Bearer $SERVICE_KEY")
        
        USER_ID=$(echo "$USER_RESPONSE" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
        echo "✅ Utilisateur existant trouvé: $USER_ID"
    else
        echo "❌ Erreur lors de la création :"
        echo "$RESPONSE"
        exit 1
    fi
fi

echo ""
echo "=========================================="
echo "📊 Exécution de la requête SQL pour créer l'admin"
echo "=========================================="
echo ""
echo "Connectez-vous au SQL Editor de Supabase et exécutez :"
echo ""
echo "SELECT public.create_admin('$EMAIL', 'super_admin');"
echo ""
echo "=========================================="
echo "✅ Setup terminé!"
echo "=========================================="
echo ""
echo "🎉 Vous pouvez maintenant vous connecter avec :"
echo "   Email: $EMAIL"
echo "   Password: $PASSWORD"
echo ""






















