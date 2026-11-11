 # =====================================================================
# MECM - Software Updates Client Settings
# =====================================================================

$SiteCode = "CHQ"
$ProviderMachineName = "CM1.corp.contoso.com"

$ClientSettingName = "GOC234 - Software Updates - Enterprise"
$CollectionName    = "All Workstations"

# ---------------------------------------------------------------------
# Import Configuration Manager Module
# ---------------------------------------------------------------------

Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" -Force

# ---------------------------------------------------------------------
# Connect to Site
# ---------------------------------------------------------------------

if (-not (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue))
{
    New-PSDrive `
        -Name $SiteCode `
        -PSProvider CMSite `
        -Root $ProviderMachineName | Out-Null
}

Set-Location "$($SiteCode):\"

# ---------------------------------------------------------------------
# Create Client Settings
# ---------------------------------------------------------------------

$ClientSettings = Get-CMClientSetting `
    -Name $ClientSettingName `
    -ErrorAction SilentlyContinue

if (-not $ClientSettings)
{
    Write-Host "Creating Client Settings: $ClientSettingName" -ForegroundColor Cyan

    $ClientSettings = New-CMClientSetting `
        -Name $ClientSettingName `
        -Type Device
}
else
{
    Write-Host "Client Settings already exist." -ForegroundColor Yellow
}

# ---------------------------------------------------------------------
# Create Schedules
# ---------------------------------------------------------------------

$ScanSchedule = New-CMSchedule `
    -RecurInterval Hours `
    -RecurCount 1 `
    -Start "00:00"

$DeploymentEvaluationSchedule = New-CMSchedule `
    -RecurInterval Hours `
    -RecurCount 1 `
    -Start "00:30"

# ---------------------------------------------------------------------
# Configure Software Updates
# ---------------------------------------------------------------------

Set-CMClientSettingSoftwareUpdate `
    -InputObject $ClientSettings `
    -Enable $true `
    -EnableInstallation $true `
    -ScanSchedule $ScanSchedule `
    -DeploymentEvaluationSchedule $DeploymentEvaluationSchedule `
    -EnableWsusCertPinning $true `
    -EnableDeltaDownload $false `
    -DeltaDownloadPort 8005 `
    -EnforceMandatory $false

# Refresh object
$ClientSettings = Get-CMClientSetting -Name $ClientSettingName

# ---------------------------------------------------------------------
# Verify Collection
# ---------------------------------------------------------------------

$Collection = Get-CMDeviceCollection `
    -Name $CollectionName `
    -ErrorAction Stop

# ---------------------------------------------------------------------
# Deploy Client Settings
# ---------------------------------------------------------------------

Write-Host "Deploying Client Settings to '$CollectionName'" -ForegroundColor Green

$ClientSettings | Start-CMClientSettingDeployment `
    -CollectionName $CollectionName

# ---------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "Deployment completed"
Write-Host "==========================================" -ForegroundColor Green

Write-Host ""
Write-Host "Client Settings : $ClientSettingName"
Write-Host "Collection      : $CollectionName"
Write-Host "Scan Schedule   : Every 1 hour starting 00:00"
Write-Host "Re-Evaluation   : Every 1 hour starting 00:30"
Write-Host "TLS Pinning     : Enabled"
Write-Host "Delta Download  : Disabled"
Write-Host "Delta Port      : 8005" 
