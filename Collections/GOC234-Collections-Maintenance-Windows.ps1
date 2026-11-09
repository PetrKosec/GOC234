# ==========================================
# MECM Demo - Maintenance Window Collection
# ==========================================

$CollectionName = "MW - Daily Servers"
$FolderName     = "Maintenance Windows"

# Vytvoření Device Collection
if (-not (Get-CMDeviceCollection -Name $CollectionName -ErrorAction SilentlyContinue))
{
    New-CMDeviceCollection `
        -Name $CollectionName `
        -LimitingCollectionName "All Systems"

    Write-Host "Collection created: $CollectionName" -ForegroundColor Green
}

# Nastavení pravidelného refresh
Set-CMCollection `
    -Name $CollectionName `
    -RefreshType Periodic

# Přesun do složky
$Collection = Get-CMDeviceCollection -Name $CollectionName

Move-CMObject `
    -InputObject $Collection `
    -FolderPath "CHQ:\DeviceCollection\$FolderName"

Write-Host "Collection moved to folder: $FolderName" -ForegroundColor Green

# Vytvoření denního Maintenance Window 14:00-16:00
$Schedule = New-CMSchedule `
    -Start (Get-Date "14:00") `
    -RecurInterval Days `
    -RecurCount 1

New-CMMaintenanceWindow `
    -CollectionName $CollectionName `
    -Name "Daily 14-16" `
    -Schedule $Schedule `
    -Duration 120

Write-Host "Maintenance Window created." -ForegroundColor Green

Write-Host ""
Write-Host "Configuration completed successfully." -ForegroundColor Cyan
