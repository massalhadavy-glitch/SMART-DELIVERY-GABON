@echo off
chcp 65001 >nul
echo.
echo ╔══════════════════════════════════════════════════════════════════════════╗
echo ║                                                                          ║
echo ║              🔐 Création du Keystore pour Smart Delivery Gabon          ║
echo ║                                                                          ║
echo ╚══════════════════════════════════════════════════════════════════════════╝
echo.
echo ⚠️  IMPORTANT : Vous allez créer le fichier de signature de votre application.
echo    Ce fichier est CRITIQUE - sans lui, vous ne pourrez plus mettre à jour
echo    votre application sur le Play Store.
echo.
echo    ⚠️  SAUVEGARDEZ CE FICHIER EN SÉCURITÉ !
echo.
pause

cd android

if not exist "keystore" (
    echo.
    echo 📁 Création du dossier keystore...
    mkdir keystore
)

echo.
echo ═══════════════════════════════════════════════════════════════════════════
echo   INFORMATIONS REQUISES
echo ═══════════════════════════════════════════════════════════════════════════
echo.
echo Vous allez devoir fournir :
echo   1. Un mot de passe pour le keystore (store password)
echo   2. Un mot de passe pour la clé (key password)
echo   3. Vos informations personnelles/organisationnelles
echo.
echo ⚠️  NOTEZ CES MOTS DE PASSE DANS UN GESTIONNAIRE DE MOTS DE PASSE !
echo.
pause

echo.
echo ═══════════════════════════════════════════════════════════════════════════
echo   RECHERCHE DE KEYTOOL
echo ═══════════════════════════════════════════════════════════════════════════
echo.

REM Chercher keytool dans les emplacements typiques
set KEYTOOL_PATH=
if exist "C:\Program Files\Java\jdk1.8.0_202\bin\keytool.exe" (
    set KEYTOOL_PATH=C:\Program Files\Java\jdk1.8.0_202\bin\keytool.exe
    goto :found_keytool
)
if exist "C:\Program Files\Java\jdk1.8.0_391\bin\keytool.exe" (
    set KEYTOOL_PATH=C:\Program Files\Java\jdk1.8.0_391\bin\keytool.exe
    goto :found_keytool
)

REM Chercher dans tous les JDK installés
for /d %%i in ("C:\Program Files\Java\jdk*") do (
    if exist "%%i\bin\keytool.exe" (
        set KEYTOOL_PATH=%%i\bin\keytool.exe
        goto :found_keytool
    )
)

REM Si keytool est dans le PATH, l'utiliser directement
where keytool >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set KEYTOOL_PATH=keytool
    goto :found_keytool
)

echo ❌ keytool introuvable !
echo.
echo Veuillez installer Java JDK ou ajouter keytool au PATH.
echo.
echo Emplacements vérifiés :
echo   - C:\Program Files\Java\jdk*\bin\keytool.exe
echo.
echo Solution : Installez Java JDK depuis https://www.oracle.com/java/technologies/downloads/
echo.
pause
exit /b 1

:found_keytool
echo ✅ keytool trouvé : %KEYTOOL_PATH%
echo.

echo ═══════════════════════════════════════════════════════════════════════════
echo   GÉNÉRATION DU KEYSTORE
echo ═══════════════════════════════════════════════════════════════════════════
echo.

"%KEYTOOL_PATH%" -genkey -v -keystore keystore/smart_delivery_gabon.jks -keyalg RSA -keysize 2048 -validity 10000 -alias smart_delivery_key

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Keystore créé avec succès !
    echo.
    echo 📍 Emplacement : android\keystore\smart_delivery_gabon.jks
    echo.
    echo ⚠️  PROCHAINES ÉTAPES :
    echo    1. Sauvegardez ce fichier en sécurité (disque externe, cloud, etc.)
    echo    2. Notez les mots de passe dans un gestionnaire de mots de passe
    echo    3. Créez le fichier key.properties (voir GUIDE_PUBLICATION_PLAYSTORE.md)
    echo.
) else (
    echo.
    echo ❌ Erreur lors de la création du keystore.
    echo    Vérifiez que Java est installé et dans le PATH.
    echo.
)

cd ..
pause

