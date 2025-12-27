@echo off
REM Script de déploiement - Politique de Confidentialité (Version Batch)
REM Ce script automatise le commit et le push des modifications

echo ========================================
echo   Déploiement Politique de Confidentialité
echo   Smart Delivery Gabon
echo ========================================
echo.

REM Vérifier que PowerShell est disponible
where powershell >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERREUR: PowerShell n'est pas installé ou non disponible dans le PATH
    echo Ce script nécessite PowerShell pour fonctionner.
    pause
    exit /b 1
)

REM Exécuter le script PowerShell
powershell.exe -ExecutionPolicy Bypass -File "%~dp0deploy_politique_confidentialite.ps1"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Script terminé avec succès!
) else (
    echo.
    echo Le script a rencontré une erreur.
)

pause










