## Windows Update Agent

### Client logs
- ScanAgent.log  
- WindowsUpdate.log  
- UpdatesDeployment.log  
- StateMessage.log - Compliance

### IIS Logs
- C:\Inetpub\logs\logFiles\W3SVC5322..  
	- Scan Job on Client  
  - IIS - ClientWebService/client.asmx - 8530 - IP Address - Windows-Update-Agent  

### SMS_STATE_SYSTEM
- Inboxes\auth\statesys.box\incoming

Usoclient.exe  
Wuinstall  

### Update Management
Wuaclt /a /DetectNow  
Wuactl /r /DetectNow  

HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU - NoAutoRebootWithLoggedOnUsers (DWORD=1)
