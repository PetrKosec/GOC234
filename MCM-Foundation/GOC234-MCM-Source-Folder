# Vytvoření adresářové struktury na E:\
# Nejprve ověří existenci složek

$folders = @(
    "E:\SOURCES",
    "E:\SOURCES\APPs",
    "E:\SOURCES\Scripts",
    "E:\SOURCES\ISO-OS",
    "E:\SOURCES\ISO-PE",
    "E:\SOURCES\Drivers",
    "E:\SOURCES\APPs\Microsoft",
    "E:\SOURCES\APPs\7-ZIP",
    "E:\SOURCES\APPs\7-ZIP\26.05",
    "E:\SOURCES\APPs\7-ZIP\26.05\x64",
    "E:\SOURCES\APPs\7-ZIP\26.05\x86",
    "E:\SOURCES\APPs\7-ZIP\23.01"
)

foreach ($folder in $folders) {
    if (-not (Test-Path -Path $folder)) {
        New-Item -Path $folder -ItemType Directory -Force | Out-Null
        Write-Host "[CREATED] $folder" -ForegroundColor Green
    }
    else {
        Write-Host "[EXISTS ] $folder" -ForegroundColor Yellow
    }
}

Write-Host "`nKontrola dokončena." -ForegroundColor Cyan
