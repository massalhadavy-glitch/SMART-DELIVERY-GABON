# ⚙️ Configuration Git - Identité

## 🔧 Problème
Git a besoin de connaître votre nom et email pour créer des commits.

## ✅ Solution

Exécutez ces commandes dans PowerShell (remplacez par vos informations) :

```powershell
git config --global user.name "Votre Nom"
git config --global user.email "votre.email@example.com"
```

### Exemple :
```powershell
git config --global user.name "John Doe"
git config --global user.email "john.doe@example.com"
```

**Note** : Utilisez l'email associé à votre compte GitHub si vous en avez un.

## 🚀 Après configuration

Une fois configuré, vous pourrez faire le commit :

```powershell
git commit -m "Initial commit - Smart Delivery Gabon"
```

---

**Besoin d'aide ?** Consultez `GUIDE_INITIALISATION_GIT.md` pour le guide complet.




