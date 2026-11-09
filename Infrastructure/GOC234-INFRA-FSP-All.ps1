#Requires -RunAsAdministrator

<#
.SYNOPSIS
Deploy Fallback Status Point Role in MECM

.NOTES
Author  : Košec Solutions
Version : 1.0
#>

#region VARIABLES

$SiteCode       = "CHQ"
$SiteServer     = "CM1.corp.contoso.com"
$FSPServer      = "CM1.corp.contoso.com"

$LogFolder      = "C:\Logs"
$LogFile        = "$LogFolder\Install-FSP.log"

$WaitTimeoutMin = 30

#endregion

#region LOGGING

if (!(Test-Path $LogFolder))
{
    New-Item -Path $LogFolder -ItemType Directory -Force | Out-Null
}

function Write-Log
{
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )

    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $Line = "$TimeStamp [$Level] $Message"

    Write-Host $Line

    Add-Content -Path $LogFile -Value $Line
}

#endregion

#region PRECHECKS

Write-Log "Starting Fallback Status Point deployment"

if (!(Test-Connection $FSPServer -Count 2 -Quiet))
{
    throw "Server $FSPServer is not reachable."
}

try
{
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" -Force
}
catch
{
    throw "Configuration Manager PowerShell module not found."
}

Set-Location "$SiteCode`:"

#endregion

#region SITE SYSTEM

Write-Log "Checking Site System Server"

$SiteSystem = Get-CMSiteSystemServer `
    -SiteSystemServerName $FSPServer `
    -ErrorAction SilentlyContinue

if (!$SiteSystem)
{
    Write-Log "Creating Site System Server"

    New-CMSiteSystemServer `
        -ServerName $FSPServer `
        -SiteCode $SiteCode

    Start-Sleep -Seconds 15
}
else
{
    Write-Log "Site System already exists"
}

#endregion

#region ROLE CHECK

$ExistingRole = Get-CMSiteSystemServer `
    -SiteSystemServerName $FSPServer |
    Get-CMSiteRole |
    Where-Object {
        $_.RoleName -eq "Fallback Status Point"
    }

if ($ExistingRole)
{
    Write-Log "Fallback Status Point already installed" "WARNING"
    return
}

#endregion

#region INSTALL ROLE

try
{
    Write-Log "Installing Fallback Status Point"

    Add-CMFallbackStatusPoint `
        -SiteSystemServerName $FSPServer `
        -ErrorAction Stop
}
catch
{
    Write-Log $_.Exception.Message "ERROR"
    throw
}

#endregion

#region WAIT FOR INSTALLATION

Write-Log "Waiting for Site Component Manager"

$Timeout = (Get-Date).AddMinutes($WaitTimeoutMin)

do
{
    Start-Sleep -Seconds 30

    $Role = Get-CMSiteSystemServer `
        -SiteSystemServerName $FSPServer |
        Get-CMSiteRole |
        Where-Object {
            $_.RoleName -eq "Fallback Status Point"
        }

    if ($Role)
    {
        break
    }

}
until ((Get-Date) -gt $Timeout)

#endregion

#region VALIDATION

$Validation = Get-CMSiteSystemServer `
    -SiteSystemServerName $FSPServer |
    Get-CMSiteRole |
    Where-Object {
        $_.RoleName -eq "Fallback Status Point"
    }

if ($Validation)
{
    Write-Log "Fallback Status Point installed successfully"
}
else
{
    Write-Log "Role installation failed" "ERROR"

    throw "Fallback Status Point not detected after installation."
}

#endregion

#region LOG INFORMATION

Write-Log "Useful logs"

Write-Log "Site Component Manager: $($ENV:SMS_LOG_PATH)\sitecomp.log"
Write-Log "Fallback Status Point: $($ENV:SMS_LOG_PATH)\fspmsi.log"

#endregion

Write-Log "Deployment completed"
