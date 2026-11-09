 Restart-Service CcmExec -Force

Start-Sleep -Seconds 10

Get-Service CcmExec |
Select-Object Name, Status 
