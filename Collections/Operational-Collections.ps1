#############################################################################
# Author  : GOC234
#
# Version : 1.0
# Created : 2026-10
#            
# Purpose : This script create a set of MCM collections and move it in an "GOC234" folder
#
#############################################################################

#Load Configuration Manager PowerShell Module
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5)+ '\ConfigurationManager.psd1')

#Get SiteCode
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-location $SiteCode":"

#Error Handling and output
Clear-Host
$ErrorActionPreference= 'SilentlyContinue'

#Create Default Folder 
$CollectionFolder = @{Name ="GOC234"; ObjectType =5000; ParentContainerNodeId =0}
Set-WmiInstance -Namespace "root\sms\site_$($SiteCode.Name)" -Class "SMS_ObjectContainerNode" -Arguments $CollectionFolder -ComputerName $SiteCode.Root
$FolderPath =($SiteCode.Name +":\DeviceCollection\" + $CollectionFolder.Name)

#Set Default limiting collections
$LimitingCollection ="All Systems"

#Refresh Schedule
$Schedule =New-CMSchedule –RecurInterval Days –RecurCount 1

#Find Existing Collections
$ExistingCollections = Get-CMDeviceCollection -Name "* | *" | Select-Object CollectionID, Name

#List of Collections Query
$DummyObject = New-Object -TypeName PSObject 
$Collections = @()

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients | All"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.Client = 1"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All devices detected by SCCM"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients | No"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.Client = 0 OR SMS_R_System.Client is NULL"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All devices without SCCM client installed"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients Version | Not Latest (2207)"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.ClientVersion not like '5.00.9088.10%'"}},@{L="LimitingCollection"
; E={"Clients | All"}},@{L="Comment"
; E={"All devices without SCCM client version 2207"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients Version | 1710"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.ClientVersion like '5.00.8577.100%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems with SCCM client version 1710 installed"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Hardware Inventory | Clients Not Reporting since 14 Days"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where ResourceId in (select SMS_R_System.ResourceID from SMS_R_System inner join SMS_G_System_WORKSTATION_STATUS on SMS_G_System_WORKSTATION_STATUS.ResourceID = SMS_R_System.ResourceId where DATEDIFF(dd,SMS_G_System_WORKSTATION_STATUS.LastHardwareScan,GetDate())
 > 14)"}},@{L="LimitingCollection" 
; E={"Clients | All"}},@{L="Comment"
; E={"All devices with SCCM client that have not communicated with hardware inventory over 14 days"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Laptops | All"}},@{L="Query"
; E={"select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System
 inner join SMS_G_System_SYSTEM_ENCLOSURE on SMS_G_System_SYSTEM_ENCLOSURE.ResourceID = SMS_R_System.ResourceId where SMS_G_System_SYSTEM_ENCLOSURE.ChassisTypes in ('8', '9', '10', '11', '12', '14', '18', '21')"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All laptops"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Laptops | Dell"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Manufacturer like '%Dell%'"}},@{L="LimitingCollection"
; E={"Laptops | All"}},@{L="Comment"
; E={"All laptops with Dell manufacturer"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Laptops | HP"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Manufacturer like '%HP%' or SMS_G_System_COMPUTER_SYSTEM.Manufacturer like '%Hewlett-Packard%'"}},@{L="LimitingCollection"
; E={"Laptops | All"}},@{L="Comment"
; E={"All laptops with HP manufacturer"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Laptops | Lenovo"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Manufacturer like '%Lenovo%'"}},@{L="LimitingCollection"
; E={"Laptops | All"}},@{L="Comment"
; E={"All laptops with Lenovo manufacturer"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Mobile Devices | Microsoft Surface"}},@{L="Query"
; E={"select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System
 inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like '%Surface%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All Windows RT mobile devices"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Mobile Devices | Microsoft Surface 4"}},@{L="Query"
; E={"select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System
 inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model = 'Surface Pro 4'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All Microsoft Surface 4"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"SCCM | Console"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_ADD_REMOVE_PROGRAMS on SMS_G_System_ADD_REMOVE_PROGRAMS.ResourceID = SMS_R_System.ResourceId where SMS_G_System_ADD_REMOVE_PROGRAMS.DisplayName like '%Configuration Manager Console%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems with SCCM console installed"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"SCCM | Site Servers"}},@{L="Query"
; E={"select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System
 where SMS_R_System.SystemRoles = 'SMS Site Server'"}},@{L="LimitingCollection"
; E={"Servers | All"}},@{L="Comment"
; E={"All systems that is SCCM site server"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"SCCM | Site Systems"}},@{L="Query"
; E={"select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System
 where SMS_R_System.SystemRoles = 'SMS Site System' or SMS_R_System.ResourceNames in (Select ServerName FROM SMS_DistributionPointInfo)"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems that is SCCM site system"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"SCCM | Distribution Points"}},@{L="Query"
; E={"select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System
 where SMS_R_System.ResourceNames in (Select ServerName FROM SMS_DistributionPointInfo)"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems that is SCCM distribution point"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Servers | All"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where OperatingSystemNameandVersion like '%Server%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All servers"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Servers | Active"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_CH_ClientSummary on SMS_G_System_CH_ClientSummary.ResourceId = SMS_R_System.ResourceId where SMS_G_System_CH_ClientSummary.ClientActiveStatus = 1 and SMS_R_System.Client = 1 and SMS_R_System.Obsolete = 0"}},@{L="LimitingCollection"
; E={"Servers | All"}},@{L="Comment"
; E={"All servers with active state"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Servers | Physical"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.ResourceId not in (select SMS_R_SYSTEM.ResourceID from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_R_System.IsVirtualMachine = 'True') and SMS_R_System.OperatingSystemNameandVersion
 like 'Microsoft Windows NT%Server%'"}},@{L="LimitingCollection"
; E={"Servers | All"}},@{L="Comment"
; E={"All physical servers"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Servers | Virtual"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.IsVirtualMachine = 'True' and SMS_R_System.OperatingSystemNameandVersion like 'Microsoft Windows NT%Server%'"}},@{L="LimitingCollection"
; E={"Servers | All"}},@{L="Comment"
; E={"All virtual servers"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Servers | Windows 2019"}},@{L="Query"
; E={"select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where OperatingSystemNameandVersion like '%Server 10%' and SMS_G_System_OPERATING_SYSTEM.BuildNumber = '17763'"}},@{L="LimitingCollection"
; E={"Servers | All"}},@{L="Comment"
; E={"All Servers with Windows 2019"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Software Inventory | Clients Not Reporting since 30 Days"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where ResourceId in (select SMS_R_System.ResourceID from SMS_R_System inner join SMS_G_System_LastSoftwareScan on SMS_G_System_LastSoftwareScan.ResourceId = SMS_R_System.ResourceId where DATEDIFF(dd,SMS_G_System_LastSoftwareScan.LastScanDate,GetDate()) > 30)"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All devices with SCCM client that have not communicated with software inventory over 30 days"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"System Health | Clients Active"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_CH_ClientSummary on SMS_G_System_CH_ClientSummary.ResourceId = SMS_R_System.ResourceId where SMS_G_System_CH_ClientSummary.ClientActiveStatus = 1 and SMS_R_System.Client = 1 and SMS_R_System.Obsolete = 0"}},@{L="LimitingCollection"
; E={"Clients | All"}},@{L="Comment"
; E={"All devices with SCCM client state active"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"System Health | Clients Inactive"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_CH_ClientSummary on SMS_G_System_CH_ClientSummary.ResourceId = SMS_R_System.ResourceId where SMS_G_System_CH_ClientSummary.ClientActiveStatus = 0 and SMS_R_System.Client = 1 and SMS_R_System.Obsolete = 0"}},@{L="LimitingCollection"
; E={"Clients | All"}},@{L="Comment"
; E={"All devices with SCCM client state inactive"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"System Health | Disabled"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.UserAccountControl ='4098'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems with client state disabled"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"System Health | Obsolete"}},@{L="Query"
; E={"select * from SMS_R_System where SMS_R_System.Obsolete = 1"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All devices with SCCM client state obsolete"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Systems | x64"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.SystemType = 'X64-based PC'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems with 64-bit system type"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Systems | Created Since 24h"}},@{L="Query"
; E={"select SMS_R_System.Name, SMS_R_System.CreationDate FROM SMS_R_System WHERE DateDiff(dd,SMS_R_System.CreationDate, GetDate()) <= 1"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems created in the last 24 hours"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Windows Update Agent | Outdated Version Win7 RTM and Lower"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_WINDOWSUPDATEAGENTVERSION on SMS_G_System_WINDOWSUPDATEAGENTVERSION.ResourceID = SMS_R_System.ResourceId inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_WINDOWSUPDATEAGENTVERSION.Version
 < '7.6.7600.256' and SMS_G_System_OPERATING_SYSTEM.Version <= '6.1.7600'"}},@{L="LimitingCollection"
; E={"Workstations | All"}},@{L="Comment"
; E={"All systems with windows update agent with outdated version Win7 RTM and lower"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Windows Update Agent | Outdated Version Win7 SP1 and Higher"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_WINDOWSUPDATEAGENTVERSION on SMS_G_System_WINDOWSUPDATEAGENTVERSION.ResourceID = SMS_R_System.ResourceId inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_WINDOWSUPDATEAGENTVERSION.Version
 < '7.6.7600.320' and SMS_G_System_OPERATING_SYSTEM.Version >= '6.1.7601'"}},@{L="LimitingCollection"
; E={"Workstations | All"}},@{L="Comment"
; E={"All systems with windows update agent with outdated version Win7 SP1 and higher"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | All"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where OperatingSystemNameandVersion like '%Workstation%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All workstations"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | Active"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_CH_ClientSummary on SMS_G_System_CH_ClientSummary.ResourceId = SMS_R_System.ResourceId where (SMS_R_System.OperatingSystemNameandVersion like 'Microsoft Windows NT%Workstation%' or SMS_R_System.OperatingSystemNameandVersion = 'Windows 7 Entreprise 6.1') and SMS_G_System_CH_ClientSummary.ClientActiveStatus = 1 and SMS_R_System.Client = 1 and SMS_R_System.Obsolete = 0"}},@{L="LimitingCollection"
; E={"Workstations | All"}},@{L="Comment"
; E={"All workstations with active state"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | Windows 10"}},@{L="Query"
; E={"select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System
 where OperatingSystemNameandVersion like '%Workstation 10.0%'"}},@{L="LimitingCollection"
; E={"Workstations | All"}},@{L="Comment"
; E={"All workstations with Windows 10 operating system"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | Windows 10 v1709"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.Build = '10.0.16299'"}},@{L="LimitingCollection"
; E={"Workstations | Windows 10"}},@{L="Comment"
; E={"All workstations with Windows 10 operating system v1709"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | Windows 10 Current Branch (CB)"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.OSBranch = '0'"}},@{L="LimitingCollection"
; E={"Workstations | Windows 10"}},@{L="Comment"
; E={"All workstations with Windows 10 CB"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | Windows 10 Current Branch for Business (CBB)"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.OSBranch = '1'"}},@{L="LimitingCollection"
; E={"Workstations | Windows 10"}},@{L="Comment"
; E={"All workstations with Windows 10 CBB"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | Windows 10 Long Term Servicing Branch (LTSB)"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.OSBranch = '2'"}},@{L="LimitingCollection"
; E={"Workstations | Windows 10"}},@{L="Comment"
; E={"All workstations with Windows 10 LTSB"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | Windows 10 Support State - Current"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 LEFT OUTER JOIN SMS_WindowsServicingStates ON SMS_WindowsServicingStates.Build = SMS_R_System.build01 AND SMS_WindowsServicingStates.branch = SMS_R_System.osbranch01 where SMS_WindowsServicingStates.State = '2'"}},@{L="LimitingCollection"
; E={"Workstations | Windows 10"}},@{L="Comment"
; E={"Windows 10 Support State - Current"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | Windows 10 Support State - Expired Soon"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 LEFT OUTER JOIN SMS_WindowsServicingStates ON SMS_WindowsServicingStates.Build = SMS_R_System.build01 AND SMS_WindowsServicingStates.branch = SMS_R_System.osbranch01 where SMS_WindowsServicingStates.State = '3'"}},@{L="LimitingCollection"
; E={"Workstations | Windows 10"}},@{L="Comment"
; E={"Windows 10 Support State - Expired Soon"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | Windows 10 Support State - Expired"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 LEFT OUTER JOIN SMS_WindowsServicingStates ON SMS_WindowsServicingStates.Build = SMS_R_System.build01 AND SMS_WindowsServicingStates.branch = SMS_R_System.osbranch01 where SMS_WindowsServicingStates.State = '4'"}},@{L="LimitingCollection"
; E={"Workstations | Windows 10"}},@{L="Comment"
; E={"Windows 10 Support State - Expired"}}

##Collection 81
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 1705"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.8201.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 1705"}}

##Collection 82
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"System Health | Clients Online"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ResourceId in (select resourceid from SMS_CollectionMemberClientBaselineStatus where SMS_CollectionMemberClientBaselineStatus.CNIsOnline = 1)"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"System Health | Clients Online"}}

##Collection 83
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | Windows 10 v1803"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Build = '10.0.17134'"}},@{L="LimitingCollection"
; E={"Workstations | Windows 10"}},@{L="Comment"
; E={"Workstations | Windows 10 v1803"}}

##Collection 84
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Channel | Monthly"}},@{L="Query"
; E={"select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from  SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceID = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.cfgUpdateChannel = 'http://officecdn.microsoft.com/pr/492350f6-3a01-4f97-b9c0-c7c6ddf67d60'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Channel | Monthly"}}

##Collection 85
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Channel | Monthly (Targeted)"}},@{L="Query"
; E={"select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from  SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceID = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.cfgUpdateChannel = 'http://officecdn.microsoft.com/pr/64256afe-f5d9-4f86-8936-8840a6a4f5be'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Channel | Monthly (Targeted)"}}

##Collection 86
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Channel | Semi-Annual (Targeted)"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceID = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.cfgUpdateChannel = 'http://officecdn.microsoft.com/pr/b8f9b850-328d-4355-9145-c59439a0c4cf'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Channel | Semi-Annual (Targeted)"}}

##Collection 87
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Channel | Semi-Annual"}},@{L="Query"
; E={"select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from  SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceID = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.cfgUpdateChannel = 'http://officecdn.microsoft.com/pr/7ffbc6bf-bc32-4f92-8982-f9dd17fd3114'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Channel | Semi-Annual"}}

##Collection 88
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients Version | 1806"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.8692.10%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems with SCCM client version 1806 installed"}}

##Collection 89
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients Version | 1810"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.8740.10%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"; E={"All systems with SCCM client version 1810 installed"}}

##Collection 90
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients Version | 1902"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.8790.10%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"; E={"All systems with SCCM client version 1902 installed"}}

##Collection 91
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"System Health | Duplicate Device Name"}},@{L="Query"
; E={"select R.ResourceID,R.ResourceType,R.Name,R.SMSUniqueIdentifier,R.ResourceDomainORWorkgroup,R.Client from SMS_R_System as r   full join SMS_R_System as s1 on s1.ResourceId = r.ResourceId   full join SMS_R_System as s2 on s2.Name = s1.Name   where s1.Name = s2.Name and s1.ResourceId != s2.ResourceId"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"; E={"All systems having a duplicate device record"}}

##Collection 92
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients Version | 1906"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.8853.10%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"; E={"All systems with SCCM client version 1906 installed"}}

##Collection 93
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | Windows 10 v1809"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Build = '10.0.17763'"}},@{L="LimitingCollection"
; E={"Workstations | Windows 10"}},@{L="Comment"
; E={"Workstations | Windows 10 v1809"}}

##Collection 94
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | Windows 10 v1903"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Build = '10.0.18362'"}},@{L="LimitingCollection"
; E={"Workstations | Windows 10"}},@{L="Comment"
; E={"Workstations | Windows 10 v1903"}}

##Collection 95
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients Version | 1910"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.8913.10%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"; E={"All systems with SCCM client version 1910 installed"}}

##Collection 96
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 1808"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.10730.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 1808"}}

##Collection 97
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 1902"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.11328.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 1902"}}

##Collection 98
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 1908"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.11929.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 1908"}}

##Collection 99
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 1912"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.12325.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 1912"}}

##Collection 100
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | Windows 10 v1909"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Build = '10.0.18363'"}},@{L="LimitingCollection"
; E={"Workstations | Windows 10"}},@{L="Comment"
; E={"Workstations | Windows 10 v1909"}}


################################# November 22th 2021 ###############################
##Collection 101
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients Version | 2002"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.8968.10%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"; E={"All systems with SCCM client version 2002 installed"}}

##Collection 102
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients Version | 2006"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.9012.10%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"; E={"All systems with SCCM client version 2006 installed"}}

##Collection 103
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients Version | 2010"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.9040.10%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"; E={"All systems with SCCM client version 2010 installed"}}

##Collection 104
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients Version | 2103"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.9049.10%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"; E={"All systems with SCCM client version 2103 installed"}}

##Collection 105
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients Version | 2107"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.9058.10%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"; E={"All systems with SCCM client version 2107 installed"}}

##Collection 109
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | Windows 10 v21H2"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.Build = '10.0.19044'"}},@{L="LimitingCollection"
; E={"Workstations | Windows 10"}},@{L="Comment"
; E={"All workstations with Windows 10 operating system v21H2"}}

##Collection 110
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | Windows 11"}},@{L="Query"
; E={"select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System
 where SMS_R_System.Build like '10.0.2%'"}},@{L="LimitingCollection"
; E={"Workstations | All"}},@{L="Comment"
; E={"All workstations with Windows 11 operating system"}}

##Collection 111
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | Windows 11 v21H2"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.Build = '10.0.22000'"}},@{L="LimitingCollection"
; E={"Workstations | Windows 11"}},@{L="Comment"
; E={"All workstations with Windows 11 operating system v21H2"}}

##Collection 112
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2001"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.12430.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2001"}}

##Collection 113
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2002"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.12527.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2002"}}

##Collection 114
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2003"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.12624.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2003"}}

##Collection 115
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2004"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.12730.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2004"}}

##Collection 116
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2005"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.12827.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2005"}}

##Collection 117
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2006"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.13001.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2006"}}

##Collection 118
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2007"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.13029.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2007"}}

##Collection 119
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2008"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.13127.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2008"}}

##Collection 120
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2009"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.13231.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2009"}}

##Collection 121
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2010"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.13328.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2010"}}

##Collection 122
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2011"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.13426.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2011"}}

##Collection 123
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2012"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.13530.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2012"}}

##Collection 124
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2101"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.13628.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2101"}}

##Collection 125
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2102"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.13801.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2102"}}

##Collection 126
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2103"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.13901.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2103"}}

##Collection 127
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2104"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.13929.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2104"}}

##Collection 128
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2105"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.14026.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2105"}}

##Collection 129
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2106"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.14131.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2106"}}

##Collection 130
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2107"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.14228.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2107"}}

##Collection 131
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2108"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.14326.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2108"}}

##Collection 132
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2109"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.14430.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2109"}}

##Collection 133
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2110"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.14527.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2110"}}

################################# August 24th 2022 ###############################

##Collection 134
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2111"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.14701.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2111"}}

##Collection 135
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2112"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.14729.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2112"}}

##Collection 136
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2201"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.14827.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2201"}}

##Collection 137
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2202"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.14931.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2202"}}

##Collection 138
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2203"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.15028.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2203"}}

##Collection 139
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2204"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.15128.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2204"}}

##Collection 140
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2205"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.15225.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2205"}}

##Collection 141
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2206"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.15330.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2206"}}

##Collection 142
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build Version | 2207"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.15427.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build Version | 2207"}}

##Collection 143
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients Version | 2111"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.9068.10%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"; E={"All systems with SCCM client version 2111 installed"}}

##Collection 144
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients Version | 2203"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.9078.10%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"; E={"All systems with SCCM client version 2203 installed"}}

##Collection 145
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients Version | 2207"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.9088.10%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"; E={"All systems with SCCM client version 2207 installed"}}

##Collection 146
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | Co-Management Enabled"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID, SMS_R_SYSTEM.ResourceType, SMS_R_SYSTEM.Name, SMS_R_SYSTEM.SMSUniqueIdentifier, SMS_R_SYSTEM.ResourceDomainORWorkgroup, SMS_R_SYSTEM.Client from SMS_R_System
inner join SMS_Client_ComanagementState on SMS_Client_ComanagementState.ResourceId = SMS_R_System.ResourceId where SMS_Client_ComanagementState.ComgmtPolicyPresent = 1 AND SMS_Client_ComanagementState.MDMEnrolled = 1 AND MDMProvisioned = 1"}},@{L="LimitingCollection"
; E={"Workstations | All"}},@{L="Comment"; E={"All workstations with SCCM client with Co-Management Enabled"}}

##Collection 147
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | Defender ATP Onboarded"}},@{L="Query"
; E={"select *  from  SMS_R_System inner join SMS_G_System_AdvancedThreatProtectionHealthStatus on SMS_G_System_AdvancedThreatProtectionHealthStatus.ResourceId = SMS_R_System.ResourceId where SMS_G_System_AdvancedThreatProtectionHealthStatus.OnboardingState = 1"}},@{L="LimitingCollection"
; E={"Workstations | All"}},@{L="Comment"; E={"All workstations with SCCM client with Defender ATP Onboarded"}}

##Collection 148
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | Defender ATP Not Onboarded"}},@{L="Query"
; E={"select *  from  SMS_R_System inner join SMS_G_System_AdvancedThreatProtectionHealthStatus on SMS_G_System_AdvancedThreatProtectionHealthStatus.ResourceId = SMS_R_System.ResourceId where SMS_G_System_AdvancedThreatProtectionHealthStatus.OnboardingState = 0"}},@{L="LimitingCollection"
; E={"Workstations | All"}},@{L="Comment"; E={"All workstations with SCCM client with Defender ATP Not Onboarded"}}

##Collection 149
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients Version | 2303"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.9106.10%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"; E={"All systems with SCCM client version 2303 installed"}}

##Collection 150
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients Version | 2309"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.9120.10%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"; E={"All systems with SCCM client version 2309 installed"}}

##Collection 151
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients Version | 2403"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.9128.10%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"; E={"All systems with SCCM client version 2403 installed"}}

##Collection 152
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | Windows 10 v22H2"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.Build = '10.0.19045'"}},@{L="LimitingCollection"
; E={"Workstations | Windows 10"}},@{L="Comment"
; E={"All workstations with Windows 10 operating system v22H2"}}

##Collection 153
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | Windows 11 v22H2"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.Build = '10.0.22621'"}},@{L="LimitingCollection"
; E={"Workstations | Windows 11"}},@{L="Comment"
; E={"All workstations with Windows 11 operating system v22H2"}}

##Collection 154
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | Windows 11 v23H2"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.Build = '10.0.22631'"}},@{L="LimitingCollection"
; E={"Workstations | Windows 11"}},@{L="Comment"
; E={"All workstations with Windows 11 operating system v23H2"}}

##Collection 155
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations | Windows 11 v24H2"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.Build = '10.0.26100'"}},@{L="LimitingCollection"
; E={"Workstations | Windows 11"}},@{L="Comment"
; E={"All workstations with Windows 11 operating system v24H2"}}


#Check Existing Collections
$Overwrite = 1
$ErrorCount = 0
$ErrorHeader = "The script has already been run. The following collections already exist in your environment:`n`r"
$ErrorCollections = @()
$ErrorFooter = "Would you like to delete and recreate the collections above? (Default : No) "
$ExistingCollections | Sort-Object Name | ForEach-Object {If($Collections.Name -Contains $_.Name) {$ErrorCount +=1 ; $ErrorCollections += $_.Name}}

#Error
If ($ErrorCount -ge1) 
    {
    Write-Host $ErrorHeader $($ErrorCollections | ForEach-Object {(" " + $_ + "`n`r")}) $ErrorFooter -ForegroundColor Yellow -NoNewline
    $ConfirmOverwrite = Read-Host "[Y/N]"
    If ($ConfirmOverwrite -ne "Y") {$Overwrite =0}
    }

#Create Collection And Move the collection to the right folder
If ($Overwrite -eq1) {
$ErrorCount =0

ForEach ($Collection
In $($Collections | Sort-Object LimitingCollection -Descending))

{
If ($ErrorCollections -Contains $Collection.Name)
    {
    Get-CMDeviceCollection -Name $Collection.Name | Remove-CMDeviceCollection -Force
    Write-host *** Collection $Collection.Name removed and will be recreated ***
    }
}

ForEach ($Collection In $($Collections | Sort-Object LimitingCollection))
{

Try 
    {
    New-CMDeviceCollection -Name $Collection.Name -Comment $Collection.Comment -LimitingCollectionName $Collection.LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection.Name -QueryExpression $Collection.Query -RuleName $Collection.Name
    Write-host *** Collection $Collection.Name created ***
    }

Catch {
        Write-host "-----------------"
        Write-host -ForegroundColor Red ("There was an error creating the: " + $Collection.Name + " collection.")
        Write-host "-----------------"
        $ErrorCount += 1
        Pause
}

Try {
        Move-CMObject -FolderPath $FolderPath -InputObject $(Get-CMDeviceCollection -Name $Collection.Name)
        Write-host *** Collection $Collection.Name moved to $CollectionFolder.Name folder***
    }

Catch {
        Write-host "-----------------"
        Write-host -ForegroundColor Red ("There was an error moving the: " + $Collection.Name +" collection to " + $CollectionFolder.Name +".")
        Write-host "-----------------"
        $ErrorCount += 1
        Pause
      }

}

If ($ErrorCount -ge1) {

        Write-host "-----------------"
        Write-Host -ForegroundColor Red "The script execution completed, but with errors."
        Write-host "-----------------"
        Pause
}

Else{
        Write-host "-----------------"
        Write-Host -ForegroundColor Green "Script execution completed without error. GOC234 Collections created sucessfully."
        Write-host "-----------------"
        Pause
    }
}

Else {
        Write-host "-----------------"
        Write-host -ForegroundColor Red ("The following collections already exist in your environment:`n`r" + $($ErrorCollections | ForEach-Object {(" " +$_ + "`n`r")}) + "Please delete all collections manually or rename them before re-executing the script! You can also select Y to do it automaticaly")
        Write-host "-----------------"
        Pause
}
