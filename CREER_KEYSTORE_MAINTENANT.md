# 🔐 Créer le Keystore - Guide Pas à Pas

## ✅ Vous êtes prêt !

La commande a été lancée mais elle attend vos informations. Suivez ces étapes :

---

## 📋 Étape 1 : Ouvrir PowerShell dans le dossier android

1. Ouvrez PowerShell
2. Naviguez vers le dossier android :
   ```powershell
   cd C:\smart_delivery-gabon_full_app\smart_delivery_gabon_full_app\android
   ```

---

## 📋 Étape 2 : Exécuter la commande

**Copiez et collez cette commande complète :**

```powershell
& "C:\Program Files\Java\jdk1.8.0_202\bin\keytool.exe" -genkey -v -keystore keystore/smart_delivery_gabon.jks -keyalg RSA -keysize 2048 -validity 10000 -alias smart_delivery_key
```

**⚠️ IMPORTANT :** Utilisez le chemin complet avec `& "..."` au début !

---

## 📝 Étape 3 : Répondre aux questions

Quand vous exécutez la commande, vous devrez répondre à ces questions :

### 1. Mot de passe du keystore
```
Entrez le mot de passe du fichier de clés : 
```
**→ Tapez un mot de passe fort** (ex: `SmartDelivery2024!`)
- ⚠️ **Le mot de passe ne s'affichera pas** (c'est normal)
- ⚠️ **NOTEZ-LE** immédiatement dans un gestionnaire de mots de passe

```
Répétez le mot de passe du fichier de clés : 
```
**→ Retapez exactement le même mot de passe**

---

### 2. Informations personnelles

```
Quel est votre nom et prénom ?
  [Unknown] : 
```
**→ Tapez :** `Smart Delivery Gabon`

```
Quel est le nom de votre unité organisationnelle ?
  [Unknown] : 
```
**→ Appuyez sur Entrée** (ou tapez votre entreprise si vous en avez une)

```
Quel est le nom de votre organisation ?
  [Unknown] : 
```
**→ Tapez :** `Smart Delivery Gabon`

```
Quel est le nom de votre ville ou localité ?
  [Unknown] : 
```
**→ Tapez votre ville** (ex: `Libreville`)

```
Quel est le nom de votre état ou province ?
  [Unknown] : 
```
**→ Tapez votre région** (ex: `Estuaire` ou appuyez sur Entrée)

```
Quel est le code pays à deux lettres pour cette unité ?
  [Unknown] : 
```
**→ Tapez :** `GA` (Gabon)

---

### 3. Confirmation

```
Est-ce CN=Smart Delivery Gabon, OU=Unknown, O=Smart Delivery Gabon, L=Libreville, ST=Estuaire, C=GA correct ?
  [non] : 
```
**→ Tapez :** `oui` ou `yes`

---

### 4. Mot de passe de la clé

```
Entrez le mot de passe de la clé pour <smart_delivery_key>
        (RETURN si identique au mot de passe du keystore) : 
```
**→ Appuyez sur Entrée** (pour utiliser le même mot de passe)
OU tapez un mot de passe différent (et notez-le aussi)

---

## ✅ Étape 4 : Vérification

Si tout s'est bien passé, vous verrez :

```
[Enregistrement de keystore dans keystore/smart_delivery_gabon.jks]
```

Et le fichier sera créé à :
```
android/keystore/smart_delivery_gabon.jks
```

---

## 🔒 Étape 5 : SAUVEGARDE IMMÉDIATE

**⚠️ CRITIQUE :** Faites ces actions MAINTENANT :

1. **Sauvegardez le fichier** `android/keystore/smart_delivery_gabon.jks` :
   - Sur un disque externe
   - Dans un service cloud sécurisé (Google Drive, Dropbox)
   - Dans un gestionnaire de mots de passe

2. **Notez les mots de passe** dans un gestionnaire de mots de passe :
   - Mot de passe du keystore
   - Mot de passe de la clé (si différent)

**Sans ce fichier et ces mots de passe, vous ne pourrez plus mettre à jour votre application !**

---

## 📝 Exemple de session complète

```
PS C:\...\android> & "C:\Program Files\Java\jdk1.8.0_202\bin\keytool.exe" -genkey -v -keystore keystore/smart_delivery_gabon.jks -keyalg RSA -keysize 2048 -validity 10000 -alias smart_delivery_key
Entrez le mot de passe du fichier de clés : [Vous tapez : SmartDelivery2024!]
Répétez le mot de passe du fichier de clés : [Vous retapez : SmartDelivery2024!]

Quel est votre nom et prénom ?
  [Unknown] : Smart Delivery Gabon

Quel est le nom de votre unité organisationnelle ?
  [Unknown] : [Entrée]

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
        (RETURN si identique au mot de passe du keystore) : [Entrée]

[Enregistrement de keystore dans keystore/smart_delivery_gabon.jks]
```

---

## 🆘 Si vous avez une erreur

### Erreur : "keytool n'est pas reconnu"
**Solution :** Utilisez le chemin complet avec `& "..."` comme dans la commande ci-dessus.

### Erreur : "Le chemin d'accès spécifié est introuvable"
**Solution :** Vérifiez que vous êtes dans le dossier `android` :
```powershell
cd C:\smart_delivery-gabon_full_app\smart_delivery_gabon_full_app\android
```

### Erreur : "Le mot de passe est trop court"
**Solution :** Utilisez un mot de passe d'au moins 6 caractères.

---

## 🎯 Prochaine étape

Une fois le keystore créé, vous devrez créer le fichier `key.properties`. 
Voir le guide : `GUIDE_PUBLICATION_PLAYSTORE.md` section "Étape 2.2"

---

**Bon courage ! 💪**


