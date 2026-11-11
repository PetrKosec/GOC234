# ============================================================
# Enable Hyper-V Enhanced Session Mode
# ============================================================

$VMHost = Get-VMHost

if (-not $VMHost.EnableEnhancedSessionMode)
{
    Write-Host "Enabling Enhanced Session Mode..." -ForegroundColor Cyan

    Set-VMHost -EnableEnhancedSessionMode $true

    Write-Host "Enhanced Session Mode enabled." -ForegroundColor Green
}
else
{
    Write-Host "Enhanced Session Mode already enabled." -ForegroundColor Yellow
}

Get-VMHost |
Select-Object ComputerName, EnableEnhancedSessionMode |
Format-Table -AutoSize
