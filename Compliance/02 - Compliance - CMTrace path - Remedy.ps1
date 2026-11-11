$CCMPath = "C:\Windows\CCM"

# Načtení systémové PATH
$CurrentPath = [Environment]::GetEnvironmentVariable(
    "Path",
    [EnvironmentVariableTarget]::Machine
)

# Rozdělení na jednotlivé položky
$Paths = $CurrentPath -split ";"

# Kontrola existence cesty
$Exists = $false

foreach ($Path in $Paths) {
    if ($Path.TrimEnd('\') -ieq $CCMPath) {
        $Exists = $true
        break
    }
}

# Přidání pouze pokud neexistuje
if (-not $Exists) {

    $NewPath = "$CurrentPath;$CCMPath"

    [Environment]::SetEnvironmentVariable(
        "Path",
        $NewPath,
        [EnvironmentVariableTarget]::Machine
    )

    Write-Output "Added $CCMPath to system PATH."
}
else {

    Write-Output "$CCMPath already exists in PATH."
}
