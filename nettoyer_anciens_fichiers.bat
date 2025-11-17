@echo off
chcp 65001 >nul
echo.
echo ╔══════════════════════════════════════════════════════════════════════════╗
echo ║                                                                          ║
echo ║              🧹 Nettoyage des anciens fichiers                          ║
echo ║                                                                          ║
echo ╚══════════════════════════════════════════════════════════════════════════╝
echo.

set OLD_DIR=android\app\src\main\kotlin\com\example

if exist "%OLD_DIR%" (
    echo.
    echo 📁 Ancien dossier MainActivity trouvé : %OLD_DIR%
    echo.
    echo ⚠️  Ce dossier contient l'ancien MainActivity avec le mauvais package.
    echo    Il peut être supprimé en toute sécurité car le nouveau MainActivity
    echo    est déjà au bon endroit : com\smartdeliverygabon\app\MainActivity.kt
    echo.
    set /p confirm="Voulez-vous supprimer ce dossier ? (O/N) : "
    if /i "%confirm%"=="O" (
        echo.
        echo 🗑️  Suppression en cours...
        rmdir /s /q "%OLD_DIR%"
        if %ERRORLEVEL% EQU 0 (
            echo ✅ Dossier supprimé avec succès !
        ) else (
            echo ❌ Erreur lors de la suppression.
        )
    ) else (
        echo.
        echo ℹ️  Suppression annulée.
    )
) else (
    echo.
    echo ✅ Aucun ancien dossier trouvé. Tout est propre !
)

echo.
echo ═══════════════════════════════════════════════════════════════════════════
echo   NETTOYAGE FLUTTER
echo ═══════════════════════════════════════════════════════════════════════════
echo.
echo Voulez-vous nettoyer le build Flutter ? (O/N)
set /p clean="Votre choix : "
if /i "%clean%"=="O" (
    flutter clean
    echo.
    echo ✅ Nettoyage terminé !
)

echo.
pause



