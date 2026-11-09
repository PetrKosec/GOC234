(Get-Command -Module ConfigurationManager).count

Get-Command -Module ConfigurationManager | Out-File "E:\SOURCES\Scripts\PowerShellCmdlets.txt"

Get-Module ConfigurationManager -ListAvailable |
Select-Object Name, Version, Path

(Get-Module ConfigurationManager).Version

Get-CMSite | Select-Object SiteCode, Version

Invoke-CMSoftwareUpdateSync

Get-CMSiteFeature | Select LocalizedDisplayName, Enabled

Get-CMSiteFeature -Fast -Name "Remove Central Administration Site" |
    Enable-CMSiteFeature -Force

Get-CMSiteFeature -Fast -Name "BitLocker Management" |
    Enable-CMSiteFeature -Force

Set-CMSite -ConsentToPreReleaseFeature $true

Get-CMSite

# Discovery details
Get-CMDiscoveryMethod -Name ActiveDirectorySystemDiscovery -SiteCode CHQ

# Boundary details
Get-CMBoundary -BoundaryName *
Get-CMBoundaryGroup

New-CMBoundary -Name "GOC234 - 10.0.0.x" -Type IPRange -Value  "10.0.0.1-10.0.0.254"

# Distribution Point
Get-CMDistributionPoint -SiteSystemServerName "CM1.corp.contoso.com" -SiteCode "CHQ"

# Management Point
Get-CMManagementPoint -SiteSystemServerName CM1.corp.contoso.com -SiteCode CHQ
Get-CMManagementPointComponent
Get-CMSiteDefinition

Add-CMManagementPoint -SiteSystemServerName CM1.corp.contoso.com -SiteCode CHQ -SqlServerFqdn "CM1.corp.contoso.com" -SqlServerInstanceName "CM1" -DatabaseName "ConfigMgr_CHQ" -ClientConnectionType Intranet -AllowDevice -GenerateAlert -EnableSsl

Set-CMManagementPoint -SiteSystemServerName "CM1.corp.contoso.com" -SiteCode "CHQ" -GenerateAlert:$True

$date = Get-Date
Get-CMSiteStatusMessage -ViewingPeriod $date.AddDays(-1) | ft -AutoSize
Get-CMSiteStatusMessage -Component SMS_MP_CONTROL_MANAGER -StartDateTime "2026-10-10"

# Creating new user / device collections
New-CMDeviceCollection -Name "Wave-1" -LimitingCollectionName "All Desktop and Server Clients"

# Handling Configuration Manager objects
Install-CMClient -DeviceName "Client1" -SiteCode "CHQ" -AlwaysInstallClient $True -IncludeDomainController $false -ForceReinstall $True
Approve-CMDevice -DeviceName "Client1"
Get-CMDevice -Name "Client1"

Block-CMDevice -DeviceName "Client1"
Unblock-CMDevice -DeviceName "Client1"

Get-CMUser -Name "CORP\Testuser1"



#Software distribution

Get-CMPackage -Fast




$Folders = @(
    "Maintenance Windows",
    "Phased Deployment"
)

foreach ($Folder in $Folders) {
    New-CMFolder `
        -ParentFolderPath "CHQ:\DeviceCollection" `
        -Name $Folder
}


(Get-Command New-CMFolder).Parameters.Keys

# Collections

New-CMDeviceCollection `
    -Name "MW - Daily 14-16" `
    -LimitingCollectionName "All Systems"


$Schedule = New-CMSchedule `
    -Start (Get-Date "14:00") `
    -RecurInterval Days `
    -RecurCount 1

New-CMMaintenanceWindow `
    -CollectionName "MW - Daily 14-16" `
    -Name "Daily 14-16" `
    -ServiceWindowType AllDeployment `
    -Schedule $Schedule `
    -Duration (New-TimeSpan -Hours 2)

Get-Command New-CMMaintenanceWindow -Syntax
(Get-Command New-CMMaintenanceWindow).Parameters.Keys
(Get-Command New-CMMaintenanceWindow).Parameters.Keys | Sort-Object


$Folders = @(
    "Test Users",
    "Groups",
    "Administrators"
)

foreach ($Folder in $Folders) {
    New-CMFolder `
        -Name $Folder `
        -ParentFolderPath "CHQ:\UserCollection"
}

