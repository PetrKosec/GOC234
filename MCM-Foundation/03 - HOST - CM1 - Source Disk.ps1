$VMName = "HYD-CM1"
$VHDPath = "E:\HYD-CM1\Virtual Hard Disks\CM1-DATA.vhdx"

if (-not (Test-Path $VHDPath))
{
    New-VHD `
        -Path $VHDPath `
        -SizeBytes 500GB `
        -Dynamic

    Write-Host "VHDX created: $VHDPath" -ForegroundColor Green
}
else
{
    Write-Host "VHDX already exists: $VHDPath" -ForegroundColor Yellow
}


if (-not (Get-VM -Name $VMName -ErrorAction SilentlyContinue))
{
    throw "Virtual machine '$VMName' was not found."
}

if (-not (Test-Path $VHDPath))
{
    throw "VHDX file '$VHDPath' was not found."
}

Add-VMHardDiskDrive `
    -VMName $VMName `
    -Path $VHDPath

Write-Host "Disk attached successfully." -ForegroundColor Green 
