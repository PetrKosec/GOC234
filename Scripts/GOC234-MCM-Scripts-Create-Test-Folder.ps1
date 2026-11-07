Get-Help New-CMScript -Examples

$ScriptPath = "C:\MECMSources\Scripts\Create-CMTestFolder.ps1"

New-CMScript `
    -ScriptName "Create C-Test Folder" `
    # -Description "Creates folder C:\Test if it does not exist" `
    -ScriptFile $ScriptPath


New-CMScript -ScriptName "Create-CM-Test-Folder" -ScriptFile "\\CM1\MECMSources\Scripts\Create-CMTestFolder.ps1" -Fast

# Approve Script
(Get-Command Approve-CMScript).Parameters.Keys

Approve-CMScript `
    -ScriptName "Create-CM-Test-Folder"

$Script = Get-CMScript -ScriptName "Create-CM-Test-Folder" -Fast
Approve-CMScript -InputObject $Script


Get-CMScript -ScriptName "Create-CM-Test-Folder" -Fast |
    Approve-CMScript

Get-CMScript -ScriptName "Create-CM-Test-Folder" -Fast |
    Deny-CMScript

(Get-Command New-CMFolder).Parameters["FolderType"]
(Get-Command New-CMFolder).Parameters.Keys
New-CMFolder


# Run Script
Invoke-CMScript `
    -ScriptName "Create C-Test Folder" `
    -CollectionName "All Workstations"
`
