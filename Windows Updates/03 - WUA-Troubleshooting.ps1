# Clearing Windows Update Cache

net stop wuauserv
net stop cryptSvc
net stop bits
net stop msiserver

ren C:\Windows\SoftwareDistribution SoftwareDistribution.old
ren C:\Windows\System32\catroot2 catroot2.old

net start wuauserv
net start cryptSvc
net start bits
net start msiserver

# WUAHandler.log

Register-PSRepository -Default
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module PsWindowsUpdate -Confirm:$false -Force

Set-ExecutionPolicy RemoteSigned -Confirm:$False

Get-WUList -MicrosoftUpdate

Windows configuration update (Other updates)

# Troubleshooting Sync process:
# HKLM\Software\Microsoft\SMS\Tracing\SMS_WSUS_SYNC_Manager
# SMS_WSUS_CONFIG_Manager

# - DebugLoggin = LogLevel = 0
