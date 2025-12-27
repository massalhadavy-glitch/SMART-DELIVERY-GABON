# Configuration WhatsApp pour Smart Delivery

## 📱 Notification automatique par WhatsApp

L'application envoie automatiquement une notification WhatsApp à l'administrateur lorsqu'une nouvelle commande est soumise.

## 🔧 Configuration

### 1. Configurer le numéro WhatsApp de l'administrateur

Ouvrez le fichier `lib/config/admin_config.dart` et modifiez le numéro :

```dart
static const String adminWhatsAppNumber = '241XXXXXXXXX';
```

**Format du numéro :**
- Code pays + numéro (sans espaces, ni + ni tirets)
- Exemple pour le Gabon : `241074123456`
  - `241` = code pays du Gabon
  - `074123456` = numéro de téléphone

### 2. Installer les dépendances

```bash
flutter pub get
```

### 3. Permissions Android

Le fichier `AndroidManifest.xml` doit contenir :

```xml
<queries>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="https" />
    </intent>
</queries>
```

### 4. Permissions iOS

Le fichier `Info.plist` doit contenir :

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>whatsapp</string>
</array>
```

## 📋 Format du message envoyé

Lorsqu'une commande est soumise, l'administrateur reçoit un message WhatsApp avec :

```
🚚 NOUVELLE COMMANDE - SMART DELIVERY

📦 Numéro de suivi: SD251028153045

📍 Détails de livraison:
• Ramassage: Libreville, Centre-ville
• Destination: Port-Gentil, Zone Industrielle
• Type de colis: Documents
• Option: Express (2H-4H)

💰 Montant: 3500 FCFA

📞 Contact client: 074123456

⏰ Date: 2025-10-28 15:30:45

✅ Statut: En attente de collecte
```

## 🚀 Activation/Désactivation

Pour activer ou désactiver les notifications WhatsApp, modifiez dans `admin_config.dart` :

```dart
static const bool enableWhatsAppNotifications = true; // ou false
```

## 🔒 Sécurité

**Important :** Ne partagez jamais le fichier `admin_config.dart` sur Git ou des plateformes publiques !

Ajoutez-le au `.gitignore` :

```
lib/config/admin_config.dart
```

## 🧪 Test

Pour tester la notification WhatsApp :

1. Configurez le bon numéro dans `admin_config.dart`
2. Lancez l'application
3. Créez une nouvelle commande
4. Validez le paiement
5. WhatsApp devrait s'ouvrir automatiquement avec le message pré-rempli
6. Cliquez sur "Envoyer" pour envoyer le message

## ❓ Problèmes courants

### WhatsApp ne s'ouvre pas
- Vérifiez que WhatsApp est installé sur l'appareil
- Vérifiez le format du numéro (pas d'espaces, pas de +)
- Vérifiez les permissions dans AndroidManifest.xml / Info.plist

### Le numéro n'est pas reconnu
- Assurez-vous d'utiliser le code pays correct
- Format : `[code pays][numéro]` (exemple: `241074123456`)
- Pas de zéro initial après le code pays

### Le message ne s'envoie pas automatiquement
- C'est normal ! Pour des raisons de sécurité, l'utilisateur doit appuyer sur "Envoyer"
- WhatsApp ouvre avec le message pré-rempli, l'utilisateur confirme l'envoi

## 📞 Support

Pour toute question, contactez l'équipe de développement.





































