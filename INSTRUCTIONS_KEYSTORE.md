# 🔐 Instructions pour créer le Keystore

## ⚠️ IMPORTANT - À LIRE AVANT DE COMMENCER

Quand vous exécuterez la commande, vous devrez fournir :

### 1. Mots de passe (À NOTER IMMÉDIATEMENT)

- **Mot de passe du keystore (store password)** : 
  - Choisissez un mot de passe fort (ex: `SmartDelivery2024!`)
  - ⚠️ **NOTEZ-LE** dans un gestionnaire de mots de passe
  
- **Mot de passe de la clé (key password)** :
  - Vous pouvez utiliser le même mot de passe
  - Ou en choisir un différent
  - ⚠️ **NOTEZ-LE** également

### 2. Informations personnelles

Quand la commande vous demandera :

- **Nom et prénom** : `Smart Delivery Gabon`
- **Unité organisationnelle** : (laissez vide ou mettez votre entreprise)
- **Organisation** : `Smart Delivery Gabon`
- **Ville ou localité** : (votre ville, ex: `Libreville`)
- **État ou province** : (votre région, ex: `Estuaire`)
- **Code pays à deux lettres** : `GA` (Gabon)

### 3. Confirmation

À la fin, vous devrez taper `oui` ou `yes` pour confirmer.

---

## 🚀 Commande à exécuter

Copiez et collez cette commande dans PowerShell :

```powershell
& "C:\Program Files\Java\jdk1.8.0_202\bin\keytool.exe" -genkey -v -keystore keystore/smart_delivery_gabon.jks -keyalg RSA -keysize 2048 -validity 10000 -alias smart_delivery_key
```

---

## 📝 Exemple de session

```
Entrez le mot de passe du keystore : [Tapez votre mot de passe, il ne s'affichera pas]
Répétez le mot de passe du keystore : [Retapez le même mot de passe]

Quel est votre nom et prénom ?
  [Unknown] : Smart Delivery Gabon

Quel est le nom de votre unité organisationnelle ?
  [Unknown] : [Appuyez sur Entrée ou tapez votre entreprise]

Quel est le nom de votre organisation ?
  [Unknown] : Smart Delivery Gabon

Quel est le nom de votre ville ou localité ?
  [Unknown] : Libreville

Quel est le nom de votre état ou province ?
  [Unknown] : Estuaire

Quel est le code pays à deux lettres pour cette unité ?
  [Unknown] : GA

Est-ce CN=Smart Delivery Gabon, OU=Unknown, O=Smart Delivery Gabon, L=Libreville, ST=Estuaire, C=GA correct ?
  [non] : oui

Entrez le mot de passe de la clé pour <smart_delivery_key>
        (RETURN si identique au mot de passe du keystore) : [Appuyez sur Entrée ou tapez un mot de passe]
```

---

## ✅ Après la création

Une fois terminé, vous devriez voir :
```
[Enregistrement de keystore dans keystore/smart_delivery_gabon.jks]
```

Et le fichier sera créé à :
```
android/keystore/smart_delivery_gabon.jks
```

---

## 🔒 Sécurité

**CRITIQUE :** Sauvegardez immédiatement :
1. Le fichier `android/keystore/smart_delivery_gabon.jks`
2. Les mots de passe (dans un gestionnaire de mots de passe)

**Sans ce fichier et ces mots de passe, vous ne pourrez plus mettre à jour votre application sur le Play Store !**



