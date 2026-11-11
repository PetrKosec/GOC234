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

# $VMName = "HYD-CM1"

Invoke-Command -VMName $VMName -ScriptBlock {

    $Disk = Get-Disk |
        Where-Object {
            $_.PartitionStyle -eq 'RAW'
        } |
        Sort-Object Size -Descending |
        Select-Object -First 1

    $Disk | Set-Disk -IsOffline $false
    $Disk | Set-Disk -IsReadOnly $false

    $Disk |
        Initialize-Disk -PartitionStyle GPT -PassThru |
        New-Partition -UseMaximumSize -DriveLetter F |
        Format-Volume `
            -FileSystem NTFS `
            -NewFileSystemLabel "CM1-DATA" `
            -Confirm:$false
} 
