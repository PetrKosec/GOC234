### LAB: Application: OpenVPN 2.7.801

Název aplikace: OpenVPN 2.7.801  
Název balíčku: OpenVPN-2.7.8-I001-amd64.msi  
Verze: 2.7.801  
Vydavatel: OpenVPN Technologies, Inc.  
Architektura: x64  
Adresa URL informací o ochraně osobních údajů: https://openvpn.net/privacy-policy/  
URL App Storu:  https://openvpn.net  

Příkazy aplikace  
Příkaz pro instalaci: "%SystemRoot%\System32\msiexec.exe" /i "OpenVPN-2.7.8-I001-amd64.msi" /qn  
Příkaz pro odinstalaci: "%SystemRoot%\System32\msiexec.exe" /X {C0D194A7-C9F7-4E55-BA12-E6A9EB25534B} /qn  

Detekce:  
Cesta: %ProgramFiles%\OpenVPN\bin  
Soubor: openvpn.exe  
Operator: Vetsi nebo rovno nez  
Hodnota: 2.7.8.0  
