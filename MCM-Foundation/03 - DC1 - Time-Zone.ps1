Invoke-Command `
    -VMName $VMName `
    -Credential $Credential `
    -ScriptBlock {

    Write-Host ""
    Write-Host "Configuring TimeZone..." -ForegroundColor Cyan
    
# Nastaví časové pásmo na středoevropský čas (ČR)
Set-TimeZone -Id "Central Europe Standard Time"
