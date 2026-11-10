param (
    [Parameter(Mandatory)]
    [String]$Reason
)

gpupdate | Out-Null

$outputString = "Refreshed Group Policy at $(Get-Date -Format 'dd.MM.yyyy hh:mm'); Reason: $Reason"

$outputString | Out-File C:\Windows\temp\MyLog.txt -Append
