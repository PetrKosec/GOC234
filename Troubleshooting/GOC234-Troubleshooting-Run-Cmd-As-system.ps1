Invoke-WebRequest -Uri https://live.sysinternals.com/psexec.exe -OutFile C:\temp\psexec.exe
Start-Process -FilePath C:\Temp\psexec.exe -ArgumentList "-i -s cmd.exe"
