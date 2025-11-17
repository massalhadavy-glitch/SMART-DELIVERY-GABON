# 📝 Modifier key.properties

## ✅ Fichier créé !

Le fichier `android/key.properties` a été créé.

---

## 🔐 Action requise : Remplir vos mots de passe

**Ouvrez le fichier :** `android/key.properties`

**Remplacez ces lignes :**

```properties
storePassword=votre_mot_de_passe_keystore
keyPassword=votre_mot_de_passe_cle
```

**Par vos vrais mots de passe :**

```properties
storePassword=VOTRE_MOT_DE_PASSE_REEL
keyPassword=VOTRE_MOT_DE_PASSE_REEL
```

**Exemple :**
Si vous avez utilisé `SmartDelivery2024!` comme mot de passe :

```properties
storePassword=SmartDelivery2024!
keyPassword=SmartDelivery2024!
keyAlias=smart_delivery_key
storeFile=../keystore/smart_delivery_gabon.jks
```

---

## 📝 Instructions

1. **Ouvrez** `android/key.properties` avec un éditeur de texte (Notepad, VS Code, etc.)

2. **Remplacez** :
   - `votre_mot_de_passe_keystore` → Le mot de passe que vous avez utilisé lors de la création du keystore
   - `votre_mot_de_passe_cle` → Le même mot de passe (ou un autre si vous en avez utilisé un différent)

3. **Sauvegardez** le fichier

4. **Vérifiez** que les lignes `keyAlias` et `storeFile` sont correctes :
   ```properties
   keyAlias=smart_delivery_key
   storeFile=../keystore/smart_delivery_gabon.jks
   ```

---

## ✅ Après modification

Une fois modifié, votre fichier devrait ressembler à :

```properties
# Fichier de configuration pour la signature de l'application
# ⚠️ NE COMMITEZ JAMAIS key.properties dans Git ! Il contient des informations sensibles.

storePassword=VotreMotDePasse123!
keyPassword=VotreMotDePasse123!
keyAlias=smart_delivery_key
storeFile=../keystore/smart_delivery_gabon.jks
```

---

## 🚀 Prochaine étape

Une fois `key.properties` modifié avec vos vrais mots de passe :

1. Vous pourrez tester le build : `flutter build appbundle --release`
2. Ou utiliser le script : `build_release.bat`

---

**Modifiez le fichier maintenant ! 💪**


