### LAB: Application: PuTTY 0.85.0.0

Název aplikace: puTTY 0.85.0.0  
Název balíčku: putty-64bit-0.85-installer.msi  
Verze: 0.85.0.0  
Vydavatel: Simon Tatham  
Architektura: x64  
Adresa URL informací o ochraně osobních údajů:  https://www.chiark.greenend.org.uk/~sgtatham/putty/  
URL App Storu:  https://www.chiark.greenend.org.uk/~sgtatham/putty  

Příkazy aplikace  
Příkaz pro instalaci: "%SystemRoot%\System32\msiexec.exe" /i "putty-64bit-0.85-installer.msi" /qn  
Příkaz pro odinstalaci: "%SystemRoot%\System32\msiexec.exe" /X {3B0346D3-155D-43E5-9561-B9BE51CF2EB6} /qn  

Detekce:  
Cesta: %ProgramFiles%\PuTTY  
Soubor: putty.exe  
Operator: Vetsi nebo rovno nez  
Hodnota: 0.85.0.0  
