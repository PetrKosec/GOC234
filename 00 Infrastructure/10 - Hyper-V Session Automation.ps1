# =====================================================================
# Hyper-V Enhanced Session Automation
# =====================================================================

# Bezpečné zadání přihlašovacích údajů
$Credential = Get-Credential `
    -UserName "CORP\LabAdmin" `
    -Message "Zadejte heslo pro CORP\LabAdmin"

$VMs = @(
    "HYD-CLIENT1",
    "HYD-CLIENT2"
)

# =====================================================================
# Enable Enhanced Session Mode on Host
# =====================================================================

Write-Host ""
Write-Host "Checking Hyper-V Host configuration..." -ForegroundColor Cyan

$VMHost = Get-VMHost

if (-not $VMHost.EnableEnhancedSessionMode)
{
    Write-Host "Enabling Enhanced Session Mode..." -ForegroundColor Yellow

    Set-VMHost -EnableEnhancedSessionMode $true

    Write-Host "Enhanced Session Mode enabled." -ForegroundColor Green
}
else
{
    Write-Host "Enhanced Session Mode already enabled." -ForegroundColor Green
}

# =====================================================================
# Process VMs
# =====================================================================

foreach ($VMName in $VMs)
{
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "Processing VM: $VMName"
    Write-Host "==================================================" -ForegroundColor Cyan

    try
    {
        $VM = Get-VM -Name $VMName -ErrorAction Stop
    }
    catch
    {
        Write-Warning "VM '$VMName' not found."
        continue
    }

    # -----------------------------------------------------------------
    # Start VM
    # -----------------------------------------------------------------

    if ($VM.State -ne "Running")
    {
        Write-Host "Starting VM..." -ForegroundColor Yellow

        Start-VM -Name $VMName | Out-Null

        do
        {
            Start-Sleep -Seconds 5
            $VM = Get-VM -Name $VMName
        }
        until ($VM.State -eq "Running")

        Write-Host "VM started." -ForegroundColor Green
    }
    else
    {
        Write-Host "VM already running." -ForegroundColor Green
    }

    # -----------------------------------------------------------------
    # Wait for Heartbeat
    # -----------------------------------------------------------------

    Write-Host "Waiting for Hyper-V Heartbeat..." -ForegroundColor Yellow

    $HeartbeatOK = $false

    for ($i = 1; $i -le 30; $i++)
    {
        $Heartbeat = Get-VMIntegrationService `
            -VMName $VMName |
            Where-Object Name -eq "Heartbeat"

        if ($Heartbeat.PrimaryStatusDescription -eq "OK")
        {
            $HeartbeatOK = $true
            break
        }

        Start-Sleep -Seconds 10
    }

    if ($HeartbeatOK)
    {
        Write-Host "Heartbeat OK." -ForegroundColor Green
    }
    else
    {
        Write-Warning "Heartbeat not ready."
    }

    # -----------------------------------------------------------------
    # Wait for PowerShell Direct
    # -----------------------------------------------------------------

    Write-Host "Waiting for PowerShell Direct..." -ForegroundColor Yellow

    $Connected = $false

    for ($i = 1; $i -le 30; $i++)
    {
        try
        {
            Invoke-Command `
                -VMName $VMName `
                -Credential $Credential `
                -ScriptBlock { "OK" } `
                -ErrorAction Stop | Out-Null

            $Connected = $true
            break
        }
        catch
        {
            Start-Sleep -Seconds 10
        }
    }

    if (-not $Connected)
    {
        Write-Warning "Unable to connect to $VMName using PowerShell Direct."
        continue
    }

    Write-Host "PowerShell Direct connected." -ForegroundColor Green

    # -----------------------------------------------------------------
    # Configure Guest OS
    # -----------------------------------------------------------------

    Invoke-Command `
        -VMName $VMName `
        -Credential $Credential `
        -ScriptBlock {

        Write-Host "Configuring Enhanced Session prerequisites..." `
            -ForegroundColor Cyan

        # --------------------------------------------------------------
        # Enable Remote Desktop
        # --------------------------------------------------------------

        Set-ItemProperty `
            -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" `
            -Name "fDenyTSConnections" `
            -Value 0

        # --------------------------------------------------------------
        # Enable Firewall Rules
        # --------------------------------------------------------------

        Enable-NetFirewallRule `
            -DisplayGroup "Remote Desktop" `
            -ErrorAction SilentlyContinue

        # --------------------------------------------------------------
        # TermService
        # --------------------------------------------------------------

        Set-Service `
            -Name "TermService" `
            -StartupType Automatic

        if ((Get-Service TermService).Status -ne "Running")
        {
            Start-Service TermService
        }

        # --------------------------------------------------------------
        # UmRdpService
        # --------------------------------------------------------------

        $UmRdpService = Get-Service `
            -Name "UmRdpService" `
            -ErrorAction SilentlyContinue

        if ($UmRdpService)
        {
            Set-Service `
                -Name "UmRdpService" `
                -StartupType Manual

            if ($UmRdpService.Status -ne "Running")
            {
                try
                {
                    Start-Service "UmRdpService" `
                        -ErrorAction Stop
                }
                catch
                {
                    Write-Warning $_.Exception.Message
                }
            }

            Write-Host "UmRdpService configured." `
                -ForegroundColor Green
        }
        else
        {
            Write-Warning "UmRdpService not found."
        }

        # --------------------------------------------------------------
        # Diagnostics
        # --------------------------------------------------------------

        Write-Host ""
        Write-Host "Diagnostics:" -ForegroundColor Cyan

        Get-Service `
            -Name TermService, UmRdpService `
            -ErrorAction SilentlyContinue |
            Select-Object Name, Status, StartType |
            Format-Table -AutoSize
    }

    # -----------------------------------------------------------------
    # Close Existing VMConnect Sessions
    # -----------------------------------------------------------------

    Write-Host "Closing existing VMConnect sessions..." -ForegroundColor Yellow

    Get-Process vmconnect -ErrorAction SilentlyContinue |
        Where-Object {
            $_.MainWindowTitle -like "*$VMName*"
        } |
        Stop-Process -Force -ErrorAction SilentlyContinue

    Start-Sleep -Seconds 3

    # -----------------------------------------------------------------
    # Reopen VM Console
    # -----------------------------------------------------------------

    Write-Host "Opening Hyper-V console..." -ForegroundColor Green

    Start-Process `
        -FilePath "vmconnect.exe" `
        -ArgumentList @("localhost", $VMName)

    Write-Host "$VMName is ready for Enhanced Session." `
        -ForegroundColor Green
}

# =====================================================================
# Summary
# =====================================================================

Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host "Enhanced Session Configuration Complete"
Write-Host "==================================================" -ForegroundColor Green

Write-Host ""
Get-VMHost |
Select-Object EnableEnhancedSessionMode

Write-Host ""
Write-Host "Processed VMs:" -ForegroundColor Cyan

$VMs | ForEach-Object {
    Write-Host " - $_"
}

Write-Host ""
Write-Host "Reconnect to the VM console if Enhanced Session"
Write-Host "is not offered immediately."
