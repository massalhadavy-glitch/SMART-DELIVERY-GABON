# 🔧 Solution : keytool introuvable

## ✅ Problème résolu !

Le script `create_keystore.bat` a été mis à jour pour détecter automatiquement `keytool`.

## 🚀 Utilisation

1. **Double-cliquez** sur `create_keystore.bat`
2. Le script cherchera automatiquement `keytool` dans :
   - `C:\Program Files\Java\jdk*\bin\keytool.exe`
   - Le PATH système

## 📍 Emplacement détecté

Votre `keytool` se trouve à :
```
C:\Program Files\Java\jdk1.8.0_202\bin\keytool.exe
```

Le script devrait maintenant le trouver automatiquement.

---

## 🔄 Alternative : Commande manuelle

Si le script ne fonctionne toujours pas, vous pouvez créer le keystore manuellement :

### Étape 1 : Aller dans le dossier android

```powershell
cd android
```

### Étape 2 : Créer le dossier keystore

```powershell
mkdir keystore
```

### Étape 3 : Créer le keystore avec le chemin complet

```powershell
& "C:\Program Files\Java\jdk1.8.0_202\bin\keytool.exe" -genkey -v -keystore keystore/smart_delivery_gabon.jks -keyalg RSA -keysize 2048 -validity 10000 -alias smart_delivery_key
```

### Informations à fournir

Quand vous exécutez la commande, vous devrez fournir :

1. **Mot de passe du keystore** (store password)
   - ⚠️ **NOTEZ-LE** dans un gestionnaire de mots de passe
   - Exemple : `MonMotDePasse123!`

2. **Mot de passe de la clé** (key password)
   - Peut être le même que le store password
   - ⚠️ **NOTEZ-LE** également

3. **Informations personnelles** :
   - Nom et prénom : `Smart Delivery Gabon`
   - Unité organisationnelle : (votre entreprise, optionnel)
   - Organisation : `Smart Delivery Gabon`
   - Ville : (votre ville)
   - État/Région : (votre région)
   - Code pays : `GA` (Gabon)

---

## ✅ Vérification

Après la création, vous devriez avoir :

```
android/keystore/smart_delivery_gabon.jks
```

---

## 📝 Prochaine étape

Une fois le keystore créé :

1. **Sauvegardez** le fichier `android/keystore/smart_delivery_gabon.jks` en sécurité
2. **Créez** le fichier `android/key.properties` (voir guide)
3. **Continuez** avec le build de production

---

## 🆘 Si ça ne fonctionne toujours pas

### Option 1 : Ajouter Java au PATH

1. Ouvrez les **Variables d'environnement** Windows
2. Ajoutez au PATH : `C:\Program Files\Java\jdk1.8.0_202\bin`
3. Redémarrez PowerShell/Terminal

### Option 2 : Utiliser Android Studio

Si vous avez Android Studio installé, il inclut aussi `keytool` :

```
C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe
```

---

**Date :** 2024  
**Projet :** Smart Delivery Gabon



