## Pending system restart
Applies to: Central administration site, primary site, secondary site  

Before you run setup, another program requires the server to be restarted.  

### To see if the computer is in a pending restart state, it checks the following registry locations:
```
HKLM:Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending

HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired

HKLM:SYSTEM\CurrentControlSet\Control\Session Manager, PendingFileRenameOperations

HKLM:Software\Microsoft\ServerManager, CurrentRebootAttempts
```
