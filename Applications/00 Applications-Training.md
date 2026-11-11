
### Offline Store
https://store.rg-adguard.net

### Chocolatey
https://community.chocolatey.org/packages

### ChatGPT Classic [9NT1R1C2HH7J]
https://apps.microsoft.com/detail/9nt1r1c2hh7j?hl=en-US&gl=U

### PowerShell: CLIENT1
winget download "9nt1r1c2hh7j" --source=msstore --accept-source-agreements --accept-package-agreements --architecture "x64"

### Application: OpenVPN

Název aplikace: OpenVPN  
Název balíčku: OpenVPN-2.7.8-I001-amd64.msi  
Verze: 2.7.801  
Vydavatel: OpenVPN Technologies, Inc.  
Architektura: x64  
Velikost aplikace: 5.61 MB  
Adresa URL informací o ochraně osobních údajů: https://openvpn.net/privacy-policy/  
URL App Storu: https://openvpn.net  

Příkazy aplikace  
Příkaz pro instalaci: "%SystemRoot%\System32\msiexec.exe" /i "OpenVPN-2.7.8-I001-amd64.msi" /qn  
Příkaz pro odinstalaci: "%SystemRoot%\System32\msiexec.exe" /X {C0D194A7-C9F7-4E55-BA12-E6A9EB25534B} /qn  

Detekce:  
Cesta: %ProgramFiles%\OpenVPN\bin  
Soubor: openvpn.exe  
Operator: Vetsi nebo rovno nez  
Hodnota: 2.7.8.0  
