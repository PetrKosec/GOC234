  # =====================================================================
# Hyper-V + CM1 Storage + MECM Source Repository
# =====================================================================
#
# Actions:
# 1. Create dynamic VHDX (500 GB) on E:
# 2. Attach VHDX to VM CM1
# 3. Online Disk
# 4. Initialize GPT
# 5. Create F:
# 6. Format NTFS
# 7. Create MECM Source Structure
# 8. Configure NTFS Permissions
# 9. Create SMB Shares
#
# SMB Permissions:
#   CORP\Domain Admins       Full
#   CORP\Domain Users        Read
#
# =====================================================================

$VMName     = "HYD-CM1"
$VHDPath    = "E:\HYD-CM1\Virtual Hard Disks\CM1-DATA.vhdx"
$VHDSize    = 500GB

$Username   = "CORP\LabAdmin"
$Password   = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential (
    $Username,
    $Password
)

# =====================================================================
# Create VHDX
# =====================================================================

if (-not (Test-Path $VHDPath))
{
    Write-Host "Creating VHDX $VHDPath ..." -ForegroundColor Cyan

    New-VHD `
        -Path $VHDPath `
        -SizeBytes $VHDSize `
        -Dynamic | Out-Null

    Write-Host "[CREATED] $VHDPath" -ForegroundColor Green
}
else
{
    Write-Host "[EXISTS ] $VHDPath" -ForegroundColor Yellow
}

# =====================================================================
# Attach VHDX
# =====================================================================

$Attached = Get-VMHardDiskDrive `
    -VMName $VMName `
    -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -eq $VHDPath }

if (-not $Attached)
{
    Write-Host "Attaching disk to VM $VMName ..." -ForegroundColor Cyan

    Add-VMHardDiskDrive `
        -VMName $VMName `
        -Path $VHDPath

    Write-Host "[CREATED] Disk attached." -ForegroundColor Green
}
else
{
    Write-Host "[EXISTS ] Disk already attached." -ForegroundColor Yellow
}

Start-Sleep -Seconds 5

# =====================================================================
# Configure Inside Guest
# =====================================================================

Invoke-Command `
    -VMName $VMName `
    -Credential $Credential `
    -ScriptBlock {

    Write-Host ""
    Write-Host "Configuring disk..." -ForegroundColor Cyan

    # ================================================================
    # Prepare Disk
    # ================================================================

    $Disk = Get-Disk |
        Where-Object {
            $_.PartitionStyle -eq "RAW"
        } |
        Sort-Object Size -Descending |
        Select-Object -First 1

    if ($Disk)
    {
        if ($Disk.IsOffline)
        {
            Set-Disk `
                -Number $Disk.Number `
                -IsOffline $false
        }

        if ($Disk.IsReadOnly)
        {
            Set-Disk `
                -Number $Disk.Number `
                -IsReadOnly $false
        }

        $Volume = $Disk |
            Initialize-Disk `
                -PartitionStyle GPT `
                -PassThru |
            New-Partition `
                -UseMaximumSize `
                -DriveLetter F

        $Volume |
            Format-Volume `
                -FileSystem NTFS `
                -NewFileSystemLabel "CM1-DATA" `
                -Confirm:$false

        Write-Host "[CREATED] F: drive" -ForegroundColor Green
    }
    else
    {
        Write-Host "[INFO    ] RAW disk not found. Assuming already configured." -ForegroundColor Yellow
    }

    # ================================================================
    # Folder Structure
    # ================================================================

    $Folders = @(
        "F:\SOURCES",
        "F:\SOURCES\APPs",
        "F:\SOURCES\Scripts",
        "F:\SOURCES\ISO-OS",
        "F:\SOURCES\ISO-PE",
        "F:\SOURCES\Drivers",
        "F:\SOURCES\OSD",
        "F:\SOURCES\Packages",

        "F:\SOURCES\APPs\Microsoft",
        "F:\SOURCES\APPs\7-ZIP",

        "F:\SOURCES\APPs\7-ZIP\26.05",
        "F:\SOURCES\APPs\7-ZIP\26.05\x64",
        "F:\SOURCES\APPs\7-ZIP\26.05\x86",

        "F:\SOURCES\APPs\7-ZIP\23.01"
    )

    foreach ($Folder in $Folders)
    {
        if (-not (Test-Path $Folder))
        {
            New-Item `
                -Path $Folder `
                -ItemType Directory `
                -Force | Out-Null

            Write-Host "[CREATED] $Folder" -ForegroundColor Green
        }
        else
        {
            Write-Host "[EXISTS ] $Folder" -ForegroundColor Yellow
        }
    }

    # ================================================================
    # NTFS Permissions
    # ================================================================

    Write-Host ""
    Write-Host "Configuring NTFS permissions..." -ForegroundColor Cyan

    $Acl = Get-Acl "F:\SOURCES"

    $Acl.SetAccessRuleProtection($true,$false)

    foreach ($Rule in @($Acl.Access))
    {
        $Acl.RemoveAccessRule($Rule) | Out-Null
    }

    $DomainAdmins = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "CORP\Domain Admins",
        "FullControl",
        "ContainerInherit,ObjectInherit",
        "None",
        "Allow"
    )

    $DomainUsers = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "CORP\Domain Users",
        "ReadAndExecute",
        "ContainerInherit,ObjectInherit",
        "None",
        "Allow"
    )

    $Acl.AddAccessRule($DomainAdmins)
    $Acl.AddAccessRule($DomainUsers)

    Set-Acl `
        -Path "F:\SOURCES" `
        -AclObject $Acl

    Write-Host "[CREATED] NTFS permissions" -ForegroundColor Green

    # ================================================================
    # SMB Shares
    # ================================================================

    $Shares = @(
        @{
            Name = "SOURCES"
            Path = "F:\SOURCES"
        },
        @{
            Name = "APPS$"
            Path = "F:\SOURCES\APPs"
        },
        @{
            Name = "OSD$"
            Path = "F:\SOURCES\OSD"
        },
        @{
            Name = "PACKAGES$"
            Path = "F:\SOURCES\Packages"
        },
        @{
            Name = "DRIVERS$"
            Path = "F:\SOURCES\Drivers"
        },
        @{
            Name = "SCRIPTS$"
            Path = "F:\SOURCES\Scripts"
        }
    )

    foreach ($Share in $Shares)
    {
        if (-not (Get-SmbShare -Name $Share.Name -ErrorAction SilentlyContinue))
        {
            New-SmbShare `
                -Name $Share.Name `
                -Path $Share.Path `
                -FullAccess "CORP\Domain Admins" `
                -ReadAccess "CORP\Domain Users" | Out-Null

            Write-Host "[CREATED] Share $($Share.Name)" -ForegroundColor Green
        }
        else
        {
            Write-Host "[EXISTS ] Share $($Share.Name)" -ForegroundColor Yellow
        }
    }

    # ================================================================
    # Summary
    # ================================================================

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host " CM1 Source Repository Ready"
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Shares:"
    Write-Host " \\CM1\SOURCES"
    Write-Host " \\CM1\APPS$"
    Write-Host " \\CM1\OSD$"
    Write-Host " \\CM1\PACKAGES$"
    Write-Host " \\CM1\DRIVERS$"
    Write-Host " \\CM1\SCRIPTS$"
    Write-Host ""
} 
