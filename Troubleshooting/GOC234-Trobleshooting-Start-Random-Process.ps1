$processArr = @("c:\Program Files\windows nt\accessories\wordpad.exe","notepad")
$launchTime = 15..25 | Get-Random
$i = 0

while ($i -lt $launchTime) {
    #$proc = Get-Random $processArr 
    Start-Process -FilePath (Get-Random $processArr)
    $i++
}
