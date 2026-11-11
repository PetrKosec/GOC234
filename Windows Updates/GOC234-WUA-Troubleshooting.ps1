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
