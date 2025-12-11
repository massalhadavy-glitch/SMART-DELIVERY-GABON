# Script de déploiement - Politique de Confidentialité
# Ce script automatise le commit et le push des modifications pour déployer la politique de confidentialité

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Déploiement Politique de Confidentialité" -ForegroundColor Cyan
Write-Host "  Smart Delivery Gabon" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier que nous sommes dans un repository Git
Write-Host "[1/5] Vérification du repository Git..." -ForegroundColor Yellow
if (-not (Test-Path .git)) {
    Write-Host "ERREUR: Ce dossier n'est pas un repository Git!" -ForegroundColor Red
    Write-Host "Exécutez ce script depuis la racine du projet." -ForegroundColor Red
    exit 1
}
Write-Host "✓ Repository Git détecté" -ForegroundColor Green
Write-Host ""

# Vérifier l'état Git
Write-Host "[2/5] Vérification de l'état Git..." -ForegroundColor Yellow
$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "Aucune modification à commiter." -ForegroundColor Yellow
    Write-Host "Vérification des commits non poussés..." -ForegroundColor Yellow
    
    $unpushed = git log origin/main..HEAD --oneline
    if ([string]::IsNullOrWhiteSpace($unpushed)) {
        Write-Host "Aucun commit à pousser. Tout est à jour!" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "Commits locaux trouvés, passage au push..." -ForegroundColor Yellow
        $skipAdd = $true
    }
} else {
    Write-Host "Modifications détectées" -ForegroundColor Green
    $skipAdd = $false
}
Write-Host ""

# Ajouter les fichiers importants
if (-not $skipAdd) {
    Write-Host "[3/5] Ajout des fichiers importants..." -ForegroundColor Yellow
    
    $filesToAdd = @(
        "web/public/politique-confidentialite.html",
        "web/vercel.json",
        "VERIFICATION_DEPLOIEMENT_VERCEL.md",
        "VERIFICATION_POLITIQUE_CONFIDENTIALITE.md",
        "VERIFICATION_DEPLOIEMENT_GITHUB.md",
        "METADONNEES_PLAYSTORE.md",
        "GUIDE_PUBLICATION_PLAYSTORE.md"
    )
    
    $addedFiles = @()
    foreach ($file in $filesToAdd) {
        if (Test-Path $file) {
            git add $file
            $addedFiles += $file
            Write-Host "  ✓ Ajouté: $file" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ Fichier non trouvé: $file" -ForegroundColor Yellow
        }
    }
    
    if ($addedFiles.Count -eq 0) {
        Write-Host "Aucun fichier à ajouter parmi ceux spécifiés." -ForegroundColor Yellow
    } else {
        Write-Host "✓ $($addedFiles.Count) fichier(s) ajouté(s)" -ForegroundColor Green
    }
    Write-Host ""
}

# Demander confirmation avant de commiter
Write-Host "[4/5] Préparation du commit..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Fichiers qui seront commités:" -ForegroundColor Cyan
git status --short
Write-Host ""

$commitMessage = "Mise à jour politique de confidentialité et configuration Vercel pour déploiement"
Write-Host "Message de commit:" -ForegroundColor Cyan
Write-Host "  $commitMessage" -ForegroundColor White
Write-Host ""

$confirmation = Read-Host "Voulez-vous continuer? (O/N)"
if ($confirmation -ne "O" -and $confirmation -ne "o" -and $confirmation -ne "Y" -and $confirmation -ne "y") {
    Write-Host "Opération annulée." -ForegroundColor Yellow
    exit 0
}

# Faire le commit
if (-not $skipAdd) {
    Write-Host ""
    Write-Host "Création du commit..." -ForegroundColor Yellow
    git commit -m $commitMessage
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Commit créé avec succès" -ForegroundColor Green
    } else {
        Write-Host 'ERREUR: Echec du commit' -ForegroundColor Red
        Write-Host 'Verifiez les messages d erreur ci-dessus.' -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}

# Pousser sur GitHub
Write-Host "[5/5] Push vers GitHub..." -ForegroundColor Yellow
Write-Host ""

# Vérifier la connexion au remote
$remote = git remote get-url origin
if ([string]::IsNullOrWhiteSpace($remote)) {
    Write-Host "ERREUR: Aucun remote 'origin' configuré!" -ForegroundColor Red
    Write-Host 'Configurez d abord le remote avec: git remote add origin [url]' -ForegroundColor Red
    exit 1
}

Write-Host "Remote: $remote" -ForegroundColor Cyan
Write-Host ""

# Demander confirmation pour le push
$pushConfirmation = Read-Host "Voulez-vous pousser sur GitHub? (O/N)"
if ($pushConfirmation -ne "O" -and $pushConfirmation -ne "o" -and $pushConfirmation -ne "Y" -and $pushConfirmation -ne "y") {
    Write-Host "Push annulé. Vous pouvez le faire manuellement plus tard avec: git push origin main" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Envoi vers GitHub..." -ForegroundColor Yellow
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✓ Déploiement réussi!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Prochaines étapes:" -ForegroundColor Cyan
    Write-Host "1. Vérifiez le déploiement Vercel (2-3 minutes)" -ForegroundColor White
    Write-Host "2. Testez l'URL: https://www.smartdeliverygabon.com/politique-confidentialite.html" -ForegroundColor White
    Write-Host "3. Ajoutez l'URL dans Google Play Console" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host 'ERREUR: Echec du push' -ForegroundColor Red
    Write-Host ""
    Write-Host "Causes possibles:" -ForegroundColor Yellow
    Write-Host '- Probleme d authentification GitHub' -ForegroundColor White
    Write-Host '- Connexion Internet' -ForegroundColor White
    Write-Host '- Conflits avec le remote' -ForegroundColor White
    Write-Host ""
    Write-Host 'Solutions:' -ForegroundColor Yellow
    Write-Host '1. Verifiez votre connexion Internet' -ForegroundColor White
    Write-Host '2. Utilisez un Personal Access Token si demande' -ForegroundColor White
    Write-Host '3. Essayez: git push origin main --force (attention: peut ecraser des commits)' -ForegroundColor White
    Write-Host ""
    exit 1
}

