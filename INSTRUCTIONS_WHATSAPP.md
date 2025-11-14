# 🚀 Instructions Rapides - Notification WhatsApp

## ⚡ Configuration en 3 étapes

### Étape 1 : Configurer le numéro WhatsApp
Ouvrez `lib/config/admin_config.dart` et remplacez :

```dart
static const String adminWhatsAppNumber = '241XXXXXXXXX';
```

Par votre vrai numéro (exemple pour le Gabon) :

```dart
static const String adminWhatsAppNumber = '241074123456';
```

**Important :** 
- Format : `[code pays][numéro]`
- Gabon : code pays = `241`
- Pas d'espaces, pas de `+`, pas de tirets

### Étape 2 : Installer les dépendances

```bash
flutter pub get
```

### Étape 3 : Compiler et tester

```bash
flutter run
```

## 📱 Comment ça marche ?

1. Un client crée une commande dans l'app
2. Il sélectionne le type de livraison (Express ou Standard)
3. Il entre son numéro Airtel Money
4. Il clique sur "Payer"
5. ✅ **WhatsApp s'ouvre automatiquement** avec un message pré-rempli
6. Le message contient tous les détails de la commande
7. L'utilisateur appuie sur "Envoyer" dans WhatsApp
8. 🎉 L'administrateur reçoit la notification !

## 📋 Exemple de message reçu

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

## 🔧 Désactiver les notifications

Dans `lib/config/admin_config.dart`, changez :

```dart
static const bool enableWhatsAppNotifications = false;
```

## ❓ Questions fréquentes

**Q : Le message s'envoie automatiquement ?**  
R : Non, pour des raisons de sécurité, l'utilisateur doit appuyer sur "Envoyer" dans WhatsApp.

**Q : Ça marche sans WhatsApp installé ?**  
R : Non, WhatsApp doit être installé sur l'appareil du client.

**Q : Puis-je utiliser WhatsApp Business ?**  
R : Oui ! L'API fonctionne avec WhatsApp et WhatsApp Business.

**Q : Comment changer le message ?**  
R : Modifiez la méthode `_buildOrderMessage()` dans `lib/services/whatsapp_service.dart`.

## 🎯 Prochaines étapes

- [ ] Remplacez le numéro par le vrai numéro de l'admin
- [ ] Testez l'envoi de notification
- [ ] Personnalisez le message si nécessaire
- [ ] Profitez ! 🎉

## 💡 Astuce Pro

Vous pouvez créer plusieurs numéros d'admin et envoyer à plusieurs personnes en appelant la fonction plusieurs fois avec différents numéros.

---

Pour plus de détails, consultez `CONFIGURATION_WHATSAPP.md`





















