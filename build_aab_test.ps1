# Script PowerShell pour générer un AAB pour Google Play Console
# Encodage UTF-8 pour l'affichage correct des caractères

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                                          ║" -ForegroundColor Cyan
Write-Host "║        📦 Génération AAB pour Test - Google Play Console                 ║" -ForegroundColor Cyan
Write-Host "║                                                                          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "Vérification de l'environnement Flutter..." -ForegroundColor Yellow
flutter doctor

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  NETTOYAGE DU PROJET" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
flutter clean

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  INSTALLATION DES DÉPENDANCES" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
flutter pub get

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  GÉNÉRATION DU APP BUNDLE (AAB) - MODE RELEASE" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  Assurez-vous que le fichier android/key.properties existe et est configuré" -ForegroundColor Yellow
Write-Host ""

flutter build appbundle --release

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅✅✅ BUILD RÉUSSI ! ✅✅✅" -ForegroundColor Green
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  📍 EMPLACEMENT DU FICHIER AAB" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   Fichier généré :" -ForegroundColor White
    Write-Host "   📦 build\app\outputs\bundle\release\app-release.aab" -ForegroundColor Green
    Write-Host ""
    
    # Vérifier la taille du fichier
    $aabPath = "build\app\outputs\bundle\release\app-release.aab"
    if (Test-Path $aabPath) {
        $fileInfo = Get-Item $aabPath
        $sizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
        Write-Host "   Taille du fichier : $($fileInfo.Length) octets (~$sizeMB MB)" -ForegroundColor White
        Write-Host ""
    }
    
    Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  📤 PROCHAINES ÉTAPES POUR GOOGLE PLAY CONSOLE" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   1. Connectez-vous à Google Play Console" -ForegroundColor White
    Write-Host "   2. Sélectionnez votre application" -ForegroundColor White
    Write-Host "   3. Allez dans 'Production' ou 'Tests internes'" -ForegroundColor White
    Write-Host "   4. Cliquez sur 'Créer une nouvelle version'" -ForegroundColor White
    Write-Host "   5. Téléversez le fichier : build\app\outputs\bundle\release\app-release.aab" -ForegroundColor White
    Write-Host "   6. Remplissez les notes de version" -ForegroundColor White
    Write-Host "   7. Enregistrez et soumettez pour révision" -ForegroundColor White
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "❌❌❌ ERREUR LORS DU BUILD ❌❌❌" -ForegroundColor Red
    Write-Host ""
    Write-Host "Vérifiez :" -ForegroundColor Yellow
    Write-Host "   - Que Flutter est correctement installé" -ForegroundColor White
    Write-Host "   - Que le fichier android/key.properties existe et est configuré" -ForegroundColor White
    Write-Host "   - Que le keystore existe et est accessible" -ForegroundColor White
    Write-Host "   - Les logs ci-dessus pour plus de détails" -ForegroundColor White
    Write-Host ""
}

Write-Host ""
Read-Host "Appuyez sur Entrée pour continuer"



