# =====================================================================
# Install MECM Fallback Status Point Site System Role
# =====================================================================

# Site Code
$SiteCode = "CHQ"

# Site Server
$SiteServer = "CM1.corp.contoso.com"

# Server, kde bude role nainstalována
$FSPServer = "CM1.corp.contoso.com"

# Připojení k Site
Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"

Set-Location "$SiteCode`:"

Write-Host "Kontrola Site System Server..." -ForegroundColor Cyan

# Kontrola existence Site System Serveru
$SiteSystem = Get-CMSiteSystemServer -SiteSystemServerName $FSPServer -ErrorAction SilentlyContinue

if (-not $SiteSystem) {
    Write-Host "Pridavam Site System Server $FSPServer" -ForegroundColor Yellow

    New-CMSiteSystemServer `
        -ServerName $FSPServer `
        -SiteCode $SiteCode
}
else {
    Write-Host "Site System Server jiz existuje." -ForegroundColor Green
}

Write-Host "Instaluji Fallback Status Point..." -ForegroundColor Cyan

# Instalace role FSP
Add-CMFallbackStatusPoint `
    -SiteSystemServerName $FSPServer

Write-Host "Fallback Status Point byl uspesne vytvoren." -ForegroundColor Green
