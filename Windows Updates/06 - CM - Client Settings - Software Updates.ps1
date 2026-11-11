# Intro
Get-Help Set-CMClientSettingSoftwareUpdate -Full

# Troubleshooting
$CS = Get-CMClientSetting -Name "Software Updates - Enterprise"
$CS | Format-List *
Get-Command Set-CMClientSettingSoftwareUpdate -Syntax
(Get-Command Set-CMClientSettingSoftwareUpdate).Parameters.Keys

# ---------------------------------------------------------------------
# Create Client Settings if not exists
# ---------------------------------------------------------------------

$ClientSettings = Get-CMClientSetting -Name $ClientSettingName -ErrorAction SilentlyContinue

if (-not $ClientSettings) {

    Write-Host "Creating Client Settings: $ClientSettingName" -ForegroundColor Cyan

    $ClientSettings = New-CMClientSetting `
        -Name $ClientSettingName `
        -Type Device
}
else {
    Write-Host "Client Settings already exist." -ForegroundColor Yellow
}

# ---------------------------------------------------------------------
# Software Updates Settings
# ---------------------------------------------------------------------

 Set-CMClientSettingSoftwareUpdate `
    -InputObject $ClientSettings `
    -Enable $true `
    -EnableInstallation $true `
    -ScanSchedule $ScanSchedule `
    -DeploymentEvaluationSchedule $DeploymentSchedule `
    -EnableDeltaDownload $false `
    -DeltaDownloadPort 8005 `
    -EnableWsusCertPinning $true `
    -EnforceMandatory $false 


# ---------------------------------------------------------------------
# Software Update Scan Schedule
# Every 1 Hour
# Effective: 00:00
# ---------------------------------------------------------------------

$ScanSchedule = New-CMSchedule `
    -RecurInterval Hours `
    -RecurCount 1 `
    -Start "00:00"

Set-CMClientSettingSoftwareUpdate `
    -InputObject $ClientSettings `
    -ScanSchedule $ScanSchedule

# ---------------------------------------------------------------------
# Software Update Deployment Re-evaluation Schedule
# Every 1 Hour
# Effective: 00:30
# ---------------------------------------------------------------------

$DeploymentSchedule = New-CMSchedule `
    -RecurInterval Hours `
    -RecurCount 1 `
    -Start "00:30"

Set-CMClientSettingSoftwareUpdate `
    -InputObject $ClientSettings `
    -DeploymentEvaluationSchedule $DeploymentSchedule

# ---------------------------------------------------------------------
# Information
# ---------------------------------------------------------------------

Write-Host ""
Write-Host "Software Update Client Settings configured." -ForegroundColor Green
Write-Host ""
Write-Host "Configured values:"
Write-Host " Enable Software Updates.................... Yes"
Write-Host " Scan Schedule.............................. Every 1 Hour starting 00:00"
Write-Host " Deployment Re-Evaluation................... Every 1 Hour starting 00:30"
Write-Host " Allow User Proxy........................... No"
Write-Host " Delta Download............................. No"
Write-Host " Delta Port................................. 8005"

# ---------------------------------------------------------------------
# Manual verification required
# ---------------------------------------------------------------------

Write-Host ""
Write-Host "Verify the following settings in the console:" -ForegroundColor Yellow
Write-Host ""
Write-Host " TLS Certificate Pinning.................... Yes"
Write-Host " Install Other Pending Deadlines............ No"
Write-Host " Pending Deadline Period.................... 1 Hour"
Write-Host " Delta Fallback To Neighbor Boundary........ No"
Write-Host " Office 365 Client Agent.................... Not Configured"  
