$VMName     = "HYD-DC1"

$Username   = "CORP\LabAdmin"
$Password   = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential (
    $Username,
    $Password
)

Invoke-Command `
    -VMName $VMName `
    -Credential $Credential `
    -ScriptBlock {

    Write-Host ""
    Write-Host "Configuring TimeZone..." -ForegroundColor Cyan
    
# Nastaví časové pásmo na středoevropský čas (ČR)
Set-TimeZone -Id "Central Europe Standard Time"
