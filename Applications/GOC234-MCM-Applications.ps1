Get-Command *cmapplication*

# Get-CMApplication
# Suspend-CMApplication
# Resume-CMApplication
# Remove-CMApplication

New-CMApplication -Name "GOC234 - PowerShell 7 Application" -Description "Gopas courseware" -SoftwareVersion "7.6.6" -Publisher "Microsoft" -AutoInstall $True
# Remove-CMApplication -Name "GOC234 - PowerShell 7 Application" -Force

New-CMFolder `
    -Name "GOC234 Applications" `
    -ParentFolderPath "CHQ:\Application"

Move-CMObject `
    -FolderPath "CHQ:\Application\GOC234 - MSI Applications" `
    -InputObject (Get-CMApplication -Name "GOC234 - PowerShell 7 Application")

$Apps = Get-CMApplication | Where-Object LocalizedDisplayName -like "GOC234*"

foreach ($App in $Apps) {
    M*ve-CMObject `
        -FolderPath *CHQ:\Application\GOC234 Applications* `
        -InputObject $App
}

Move-CMObject `
    -FolderPath "CHQ:\Application\GOC234 Applications" `
    -InputObject (Get-CMApplication -Name "GOC234 - PowerShell 7 Application")
