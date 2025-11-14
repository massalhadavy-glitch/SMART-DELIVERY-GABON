# 🚚 Smart Delivery Gabon

Application de livraison express pour le Gabon avec notifications WhatsApp automatiques.

## ✨ Fonctionnalités

- 📦 Création et suivi de colis en temps réel
- 💳 Paiement via Airtel Money
- 🚀 Options de livraison Express (2-4H) ou Standard (-48H)
- 📱 **Notification WhatsApp automatique à l'administrateur**
- 🔐 Authentification utilisateur avec Supabase
- 📊 Tableau de bord administrateur
- 🎨 Interface moderne et intuitive

## 🚀 Installation Rapide

1. **Cloner le projet**
```bash
git clone [url-du-repo]
cd smart_delivery_gabon_full_app
```

2. **Configurer Supabase**
```bash
# Copiez le fichier exemple
cp lib/config/supabase_config.example.dart lib/config/supabase_config.dart
# Éditez et ajoutez vos credentials Supabase
```

3. **Configurer WhatsApp** ⭐ NOUVEAU
```bash
# Copiez le fichier exemple
cp lib/config/admin_config.example.dart lib/config/admin_config.dart
# Éditez et ajoutez le numéro WhatsApp de l'admin (format: 241XXXXXXXXX)
```

4. **Installer les dépendances**
```bash
flutter pub get
```

5. **Lancer l'application**
```bash
flutter run
```

## 📱 Configuration WhatsApp

### Configuration du numéro administrateur

Ouvrez `lib/config/admin_config.dart` :

```dart
static const String adminWhatsAppNumber = '241074123456'; // Votre numéro
```

**Format du numéro :**
- Code pays + numéro (sans espaces)
- Exemple Gabon : `241074123456`

### Comment ça marche ?

1. Client crée une commande
2. Valide le paiement
3. **WhatsApp s'ouvre automatiquement** avec message pré-rempli
4. Client confirme l'envoi
5. Admin reçoit tous les détails de la commande !

📖 **Documentation complète :** [INSTRUCTIONS_WHATSAPP.md](INSTRUCTIONS_WHATSAPP.md)

## 📋 Structure du Projet

```
lib/
├── config/
│   ├── supabase_config.dart       # Configuration Supabase
│   └── admin_config.dart          # Configuration admin (WhatsApp)
├── models/
│   └── package.dart               # Modèle de données
├── providers/
│   ├── auth_notifier.dart         # Gestion authentification
│   └── package_notifier.dart      # Gestion des colis
├── screens/
│   ├── splash_screen.dart         # Écran de démarrage
│   ├── landing_page.dart          # Page d'accueil
│   ├── login_page.dart            # Connexion
│   ├── payment_confirmation_page.dart  # Confirmation paiement + WhatsApp
│   └── ...
├── services/
│   ├── supabase_service.dart      # Service Supabase
│   └── whatsapp_service.dart      # Service WhatsApp (NOUVEAU)
└── main.dart
```

## 🔧 Technologies Utilisées

- **Flutter** - Framework UI
- **Supabase** - Backend et authentification
- **Provider** - Gestion d'état
- **url_launcher** - Intégration WhatsApp
- **intl** - Formatage dates

## 📚 Documentation

- [CONFIGURATION_SUPABASE.md](CONFIGURATION_SUPABASE.md) - Configuration Supabase
- [CONFIGURATION_WHATSAPP.md](CONFIGURATION_WHATSAPP.md) - Configuration WhatsApp détaillée
- [INSTRUCTIONS_WHATSAPP.md](INSTRUCTIONS_WHATSAPP.md) - Guide rapide WhatsApp
- [DEPLOYMENT.md](docs/DEPLOYMENT.md) - Guide de déploiement

## 🔒 Sécurité

⚠️ **Important :** Ne partagez jamais ces fichiers sur Git :
- `lib/config/supabase_config.dart`
- `lib/config/admin_config.dart`

Ces fichiers sont déjà dans `.gitignore`.

## 🐛 Dépannage

### WhatsApp ne s'ouvre pas
- Vérifiez que WhatsApp est installé
- Vérifiez le format du numéro (pas d'espaces, pas de +)
- Vérifiez les permissions dans AndroidManifest.xml / Info.plist

### Problème de connexion Supabase
- Vérifiez vos credentials dans `supabase_config.dart`
- Consultez `CONFIGURATION_SUPABASE.md`

## 📞 Support

Pour toute question ou problème :
- Consultez la documentation dans le dossier du projet
- Vérifiez les fichiers `SOLUTION_*.md` pour les problèmes courants

## 📄 Licence

Ce projet est propriétaire. Tous droits réservés.

---

**Version:** 1.0.0  
**Dernière mise à jour:** Octobre 2025
