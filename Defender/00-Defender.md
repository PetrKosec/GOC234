## Microsoft Defender Antivirus
```
Get-MPComputerStatus
(Get-MPComputerStatus).RealTimeProtectionEnabled
(Get-MPComputerStatus).AntivirusSignatureVersion
(Get-MPComputerStatus).AntivirusSignatureLastUpdated
Get-MpComputerStatus | Select-Object AMEngineVersion, AntivirusSignatureVersion, AntivirusSignatureLastUpdated
```
AMEngineVersion (verze skenovacího jádra)  
AntivirusSignatureVersion (Security Intelligence version) - verze virových definic: 1.459.216.0  
AntivirusSignatureLastUpdate (čas poslední aktualizace)
## Jak pustit aktualizaci ručně: Update

### Kontrola historie zablokovaných hrozeb
```
Get-MpThreat
```
Konfigurace počítače > Šablony pro správu > Součásti systému Windows > Antivirová ochrana v programu Microsoft Defender > Aktualizace podpisu

### Task Scheduler
```
"C:\Program Files\Windows Defender\MpCmdRun.exe"
```

```
$Action = New-ScheduledTaskAction -Execute '"C:\Program Files\Windows Defender\MpCmdRun.exe"' -Argument "-SignatureUpdate"
$Trigger = New-ScheduledTaskTrigger -Daily -At 12:00PM
Register-ScheduledTask -TaskName "Defender_AutoUpdate_Custom" -Action $Action -Trigger $Trigger -User "NT AUTHORITY\SYSTEM" -RunLevel Highest
```
