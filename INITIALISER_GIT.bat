@echo off
echo ========================================
echo Initialisation Git - Smart Delivery Gabon
echo ========================================
echo.

REM Vérifier si Git est installé
git --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Git n'est pas installe!
    echo Telechargez Git depuis: https://git-scm.com/download/win
    pause
    exit /b 1
)

echo [OK] Git est installe
echo.

REM Initialiser Git si ce n'est pas déjà fait
if not exist .git (
    echo Initialisation du repository Git...
    git init
    echo [OK] Repository Git initialise
) else (
    echo [OK] Repository Git deja initialise
)
echo.

REM Ajouter tous les fichiers
echo Ajout des fichiers...
git add .
echo [OK] Fichiers ajoutes
echo.

REM Faire le commit initial
echo Creation du commit initial...
git commit -m "Initial commit - Smart Delivery Gabon"
if errorlevel 1 (
    echo [ATTENTION] Aucun changement a commiter ou commit deja fait
) else (
    echo [OK] Commit initial cree
)
echo.

echo ========================================
echo ETAPES SUIVANTES:
echo ========================================
echo 1. Creez un repository sur GitHub
echo 2. Executez ces commandes (remplacez l'URL):
echo    git remote add origin https://github.com/VOTRE-USERNAME/smart-delivery-gabon.git
echo    git branch -M main
echo    git push -u origin main
echo.
echo Pour plus de details, consultez: GUIDE_INITIALISATION_GIT.md
echo.
pause

