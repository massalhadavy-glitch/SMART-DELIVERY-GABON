# 🧪 Test de l'intégration WhatsApp

## ✅ Checklist de test

### Avant de tester

- [ ] Vous avez configuré le numéro dans `lib/config/admin_config.dart`
- [ ] Vous avez exécuté `flutter pub get`
- [ ] WhatsApp est installé sur votre appareil de test
- [ ] Vous avez un appareil physique ou un émulateur avec WhatsApp

### Tests fonctionnels

#### Test 1 : Configuration
- [ ] Le fichier `lib/config/admin_config.dart` existe
- [ ] Le numéro WhatsApp est au bon format (ex: 241074123456)
- [ ] `enableWhatsAppNotifications` est à `true`

#### Test 2 : Compilation
```bash
flutter clean
flutter pub get
flutter run
```
- [ ] L'application compile sans erreur
- [ ] Aucune erreur de dépendance

#### Test 3 : Navigation
- [ ] Le splash screen s'affiche au démarrage
- [ ] La navigation vers la landing page fonctionne
- [ ] La création de commande est accessible

#### Test 4 : Création de commande
- [ ] Remplir tous les champs (adresse ramassage, destination, type)
- [ ] Sélectionner une option de livraison (Express ou Standard)
- [ ] Le coût s'affiche correctement
- [ ] Entrer un numéro Airtel Money
- [ ] Cliquer sur "Payer"

#### Test 5 : Notification WhatsApp ⭐
- [ ] Après 3 secondes de traitement, WhatsApp s'ouvre automatiquement
- [ ] Le message est pré-rempli avec tous les détails :
  - Numéro de suivi
  - Adresse de ramassage
  - Adresse de destination
  - Type de colis
  - Option de livraison
  - Montant
  - Numéro du client
  - Date et heure
- [ ] Le destinataire est le bon numéro (admin)
- [ ] Le message est lisible et bien formaté
- [ ] Vous pouvez envoyer le message en cliquant sur "Envoyer"

#### Test 6 : Retour à l'application
- [ ] Après l'envoi WhatsApp, retour possible à l'application
- [ ] La commande apparaît dans la liste des commandes
- [ ] Le numéro de suivi est correct
- [ ] Le statut est "En attente de collecte"

### Tests d'erreur

#### Test 7 : WhatsApp non installé
- [ ] Désinstaller WhatsApp
- [ ] Créer une commande
- [ ] Vérifier que l'application ne crash pas
- [ ] Vérifier les logs : doit afficher "Impossible d'ouvrir WhatsApp"

#### Test 8 : Numéro invalide
- [ ] Changer le numéro dans `admin_config.dart` pour un numéro invalide (ex: "123")
- [ ] Créer une commande
- [ ] Vérifier que l'application ne crash pas

#### Test 9 : Désactivation
- [ ] Mettre `enableWhatsAppNotifications = false`
- [ ] Créer une commande
- [ ] WhatsApp ne doit PAS s'ouvrir
- [ ] La commande doit quand même être créée

## 📊 Résultats attendus

### ✅ Test réussi si :
1. WhatsApp s'ouvre automatiquement après le paiement
2. Le message contient toutes les informations
3. Le message peut être envoyé à l'admin
4. L'application ne crash jamais
5. La commande est enregistrée correctement

### ❌ Test échoué si :
1. L'application crash
2. WhatsApp ne s'ouvre pas (alors qu'il est installé)
3. Le message est vide ou incomplet
4. Le mauvais numéro est contacté
5. La commande n'est pas enregistrée

## 🔧 Debugging

### Vérifier les logs
```bash
flutter run --verbose
```

Recherchez dans les logs :
- `✅ Notification WhatsApp envoyée à l'administrateur`
- `⚠️ Échec de l'envoi de la notification WhatsApp`
- `❌ Impossible d'ouvrir WhatsApp`
- `❌ Erreur lors de l'envoi WhatsApp:`

### Console de debug
Dans le code, vous pouvez ajouter :
```dart
debugPrint('Numéro admin: ${AdminConfig.adminWhatsAppNumber}');
debugPrint('Notifications activées: ${AdminConfig.enableWhatsAppNotifications}');
```

## 📱 Test sur différentes plateformes

### Android
- [ ] Test sur émulateur Android
- [ ] Test sur appareil physique Android
- [ ] Vérifier les permissions dans AndroidManifest.xml

### iOS
- [ ] Test sur simulateur iOS (Note: WhatsApp ne fonctionne pas sur simulateur)
- [ ] Test sur appareil physique iOS
- [ ] Vérifier les permissions dans Info.plist

## 🎯 Scénarios de test avancés

### Scénario 1 : Commande express
- Type : Documents
- Option : Express (2H-4H)
- Coût attendu : 3500 FCFA
- [ ] Le message WhatsApp affiche le bon montant

### Scénario 2 : Commande standard
- Type : Colis volumineux
- Option : Standard (-48H)
- Coût attendu : 2000 FCFA
- [ ] Le message WhatsApp affiche le bon montant

### Scénario 3 : Plusieurs commandes
- [ ] Créer 3 commandes d'affilée
- [ ] Vérifier que WhatsApp s'ouvre pour chaque commande
- [ ] Vérifier que les numéros de suivi sont différents

## 📝 Rapport de test

Date du test : _______________
Testé par : _______________
Appareil : _______________
Version Flutter : _______________

Résultat global : ⬜ PASS  ⬜ FAIL

Commentaires :
___________________________________
___________________________________
___________________________________

---

**Note :** Ce document est un guide de test. Adaptez-le selon vos besoins spécifiques.





































