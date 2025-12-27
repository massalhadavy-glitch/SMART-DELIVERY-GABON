@echo off
chcp 65001 >nul
echo.
echo ╔══════════════════════════════════════════════════════════════════════════╗
echo ║                                                                          ║
echo ║        📦 Génération AAB pour Test - Google Play Console                 ║
echo ║                                                                          ║
echo ╚══════════════════════════════════════════════════════════════════════════╝
echo.

echo Vérification de l'environnement Flutter...
flutter doctor

echo.
echo ═══════════════════════════════════════════════════════════════════════════
echo   NETTOYAGE DU PROJET
echo ═══════════════════════════════════════════════════════════════════════════
echo.
flutter clean

echo.
echo ═══════════════════════════════════════════════════════════════════════════
echo   INSTALLATION DES DÉPENDANCES
echo ═══════════════════════════════════════════════════════════════════════════
echo.
flutter pub get

echo.
echo ═══════════════════════════════════════════════════════════════════════════
echo   GÉNÉRATION DU APP BUNDLE (AAB) - MODE RELEASE
echo ═══════════════════════════════════════════════════════════════════════════
echo.
echo ⚠️  Assurez-vous que le fichier android/key.properties existe et est configuré
echo.

flutter build appbundle --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅✅✅ BUILD RÉUSSI ! ✅✅✅
    echo.
    echo ═══════════════════════════════════════════════════════════════════════════
    echo   📍 EMPLACEMENT DU FICHIER AAB
    echo ═══════════════════════════════════════════════════════════════════════════
    echo.
    echo    Fichier généré :
    echo    📦 build\app\outputs\bundle\release\app-release.aab
    echo.
    echo ═══════════════════════════════════════════════════════════════════════════
    echo   📤 PROCHAINES ÉTAPES POUR GOOGLE PLAY CONSOLE
    echo ═══════════════════════════════════════════════════════════════════════════
    echo.
    echo    1. Connectez-vous à Google Play Console
    echo    2. Sélectionnez votre application
    echo    3. Allez dans "Production" ou "Tests internes"
    echo    4. Cliquez sur "Créer une nouvelle version"
    echo    5. Téléversez le fichier : build\app\outputs\bundle\release\app-release.aab
    echo    6. Remplissez les notes de version
    echo    7. Enregistrez et soumettez pour révision
    echo.
    echo ═══════════════════════════════════════════════════════════════════════════
    echo.
    
    REM Vérifier si le fichier existe et afficher sa taille
    if exist "build\app\outputs\bundle\release\app-release.aab" (
        for %%A in ("build\app\outputs\bundle\release\app-release.aab") do (
            set /a size=%%~zA/1024/1024
            echo    Taille du fichier : %%~zA octets (~%%~zA/1024/1024 MB)
        )
    )
    echo.
) else (
    echo.
    echo ❌❌❌ ERREUR LORS DU BUILD ❌❌❌
    echo.
    echo Vérifiez :
    echo    - Que Flutter est correctement installé
    echo    - Que le fichier android/key.properties existe et est configuré
    echo    - Que le keystore existe et est accessible
    echo    - Les logs ci-dessus pour plus de détails
    echo.
)

echo.
pause



