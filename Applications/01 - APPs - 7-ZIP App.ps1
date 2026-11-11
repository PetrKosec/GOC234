Import-Module $ENV:SMS_ADMIN_UI_PATH.Replace("bin\i386","bin\ConfigurationManager.psd1")

Set-Location CHQ:

$Applications = @(
    @{
        Name = "7-Zip 23.01 x64"
        Version = "23.01"
        Arch = "x64"
    },
    @{
        Name = "7-Zip 23.01 x86"
        Version = "23.01"
        Arch = "x86"
    },
    @{
        Name = "7-Zip 26.04 x64"
        Version = "26.04"
        Arch = "x64"
    },
    @{
        Name = "7-Zip 26.04 x86"
        Version = "26.04"
        Arch = "x86"
    }
)

foreach ($App in $Applications)
{
    $ContentPath = "E:\Sources\APPs\7-ZIP\$($App.Version)\$($App.Arch)"

    Write-Host ""
    Write-Host "Processing $($App.Name)" -ForegroundColor Cyan

    if (-not (Test-Path $ContentPath))
    {
        Write-Warning "Path not found: $ContentPath"
        continue
    }

    $Msi = Microsoft.PowerShell.Management\Get-ChildItem `
        -Path $ContentPath `
        -Filter "*.msi" |
        Select-Object -First 1

    if (-not $Msi)
    {
        Write-Warning "No MSI found in $ContentPath"
        continue
    }

    Write-Host "MSI: $($Msi.FullName)" -ForegroundColor Green

    $ExistingApp = Get-CMApplication `
        -Name $App.Name `
        -Fast `
        -ErrorAction SilentlyContinue

    if ($ExistingApp)
    {
        Write-Host "$($App.Name) already exists." -ForegroundColor Yellow
        continue
    }

    $Installer = New-Object -ComObject WindowsInstaller.Installer

    $Database = $Installer.GetType().InvokeMember(
        "OpenDatabase",
        "InvokeMethod",
        $null,
        $Installer,
        @($Msi.FullName, 0)
    )

    $View = $Database.OpenView(
        "SELECT Value FROM Property WHERE Property='ProductCode'"
    )

    $View.Execute()

    $Record = $View.Fetch()

    $ProductCode = $Record.StringData(1)

    Write-Host "ProductCode: $ProductCode" -ForegroundColor Yellow

    New-CMApplication `
        -Name $App.Name `
        -Publisher "7-Zip" `
        -SoftwareVersion $App.Version `
        -AutoInstall $true

    Add-CMMsiDeploymentType `
        -ApplicationName $App.Name `
        -DeploymentTypeName "MSI" `
        -ContentLocation $Msi.FullName `
        -ProductCode $ProductCode `
        -InstallationBehaviorType InstallForSystem `
        -LogonRequirementType WhetherOrNotUserLoggedOn `
        -MaximumRuntimeMins 15 `
        -EstimatedRuntimeMins 2

    Write-Host "$($App.Name) created successfully." -ForegroundColor Green
}

Write-Host ""
Write-Host "Completed." -ForegroundColor Green
