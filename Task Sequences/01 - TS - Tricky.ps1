SMSTSRebootDelay 5

# Install cs-CZ LP
dism.exe /Image:%OSDTargetSystemDrive%\ /ScratchDir:%OSDTargetSystemDrive%\Windows\Temp /Add-Package /PackagePath:".\Microsoft-Windows-Client-Language-Pack_x64_cs-cz.cab"

# Disable Widgets
reg.exe add HKLM\SOFTWARE\Policies\Microsoft\DSH /v AllowNewsAndInterests /t REG_DWORD /d 0 /f

# Uninstall default Teams:
Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "MicrosoftTeams*"} | Remove-AppxProvisionedPackage -Online

# Disable basic Teams auto-install
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications /v ConfigureChatAutoInstall /t REG_DWORD /d 0 /f


Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "Microsoft.BingNews*"} | Remove-AppxProvisionedPackage -Online
Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "Microsoft.BingWeather*"} | Remove-AppxProvisionedPackage -Online
Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "Microsoft.Xbox.TCUI*"} | Remove-AppxProvisionedPackage -Online
Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "Microsoft.XboxGameOverlay*"} | Remove-AppxProvisionedPackage -Online
Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "Microsoft.XboxGamingOverlay*"} | Remove-AppxProvisionedPackage -Online
Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "Microsoft.XboxIdentityProvider*"} | Remove-AppxProvisionedPackage -Online
Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "Microsoft.XboxSpeechToTextOverlay*"} | Remove-AppxProvisionedPackage -Online
Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "Microsoft.YourPhone*"} | Remove-AppxProvisionedPackage -Online
Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "Microsoft.ZuneMusic*"} | Remove-AppxProvisionedPackage -Online
Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "Microsoft.ZuneVideo*"} | Remove-AppxProvisionedPackage -Online

# My Pc icon
REG ADD "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /V {20D04FE0-3AEA-1069-A2D8-08002B30309D} /T REG_DWORD /D 0 /F
