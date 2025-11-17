@echo off
chcp 65001 >nul
echo.
echo ╔══════════════════════════════════════════════════════════════════════════╗
echo ║                                                                          ║
echo ║              🏗️  Build de Production - Smart Delivery Gabon              ║
echo ║                                                                          ║
echo ╚══════════════════════════════════════════════════════════════════════════╝
echo.

echo Vérification de l'environnement...
flutter doctor

echo.
echo ═══════════════════════════════════════════════════════════════════════════
echo   NETTOYAGE
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
echo   BUILD APP BUNDLE (pour Play Store)
echo ═══════════════════════════════════════════════════════════════════════════
echo.
flutter build appbundle --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Build réussi !
    echo.
    echo 📍 Fichier généré :
    echo    build\app\outputs\bundle\release\app-release.aab
    echo.
    echo 📤 Vous pouvez maintenant télécharger ce fichier dans Google Play Console
    echo.
) else (
    echo.
    echo ❌ Erreur lors du build.
    echo    Vérifiez les logs ci-dessus pour plus de détails.
    echo.
)

echo.
echo Voulez-vous aussi créer un APK pour les tests ? (O/N)
set /p choice="Votre choix : "
if /i "%choice%"=="O" (
    echo.
    echo ═══════════════════════════════════════════════════════════════════════════
    echo   BUILD APK (pour tests)
    echo ═══════════════════════════════════════════════════════════════════════════
    echo.
    flutter build apk --release
    if %ERRORLEVEL% EQU 0 (
        echo.
        echo ✅ APK créé avec succès !
        echo.
        echo 📍 Fichier généré :
        echo    build\app\outputs\flutter-apk\app-release.apk
        echo.
    )
)

pause



